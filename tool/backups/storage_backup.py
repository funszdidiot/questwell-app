"""Bounded, manual Storage-only backup; source operations are list/get only."""
import datetime as dt
import hashlib
import io
import json
import os
import sys
import tarfile
import uuid

SOURCE_REF = "bdzcazkyypopbanbjnud"
SOURCE_BUCKET = "beta-feedback"
DEST_BUCKET = "questwell-backups-20261009"
PREFIX = "questwell/"
MAX_FILE = 16 * 1024 * 1024
MAX_SOURCE = 128 * 1024 * 1024
MAX_DEST = 512 * 1024 * 1024
MAX_OBJECTS = 1000


class BackupError(Exception):
    pass


def inventory(client, bucket, prefix="", max_bytes=MAX_SOURCE, max_objects=MAX_OBJECTS):
    found, total, token, seen_tokens = {}, 0, None, set()
    while True:
        args = {"Bucket": bucket, "Prefix": prefix, "MaxKeys": 1000}
        if token:
            args["ContinuationToken"] = token
        page = client.list_objects_v2(**args)
        for item in page.get("Contents", []):
            key, size = item["Key"], item["Size"]
            if key in found or not isinstance(size, int) or size < 0:
                raise BackupError("invalid or duplicate listing")
            total += size
            if total > max_bytes or len(found) >= max_objects:
                raise BackupError("inventory safety limit exceeded")
            found[key] = {"size": size, "etag": item["ETag"],
                          "modified": item["LastModified"].isoformat()}
        if not page.get("IsTruncated", False):
            return found, total
        token = page.get("NextContinuationToken")
        if not token or token in seen_tokens:
            raise BackupError("incomplete listing")
        seen_tokens.add(token)


def read_bounded(response, limit):
    stream = response["Body"]
    try:
        value = stream.read(limit + 1)
    finally:
        stream.close()
    if len(value) > limit:
        raise BackupError("download exceeds limit")
    return value


def add_member(archive, name, data):
    info = tarfile.TarInfo(name)
    info.size, info.mode, info.mtime = len(data), 0o600, 0
    archive.addfile(info, io.BytesIO(data))


def build_snapshot(source):
    buckets = {item["Name"] for item in source.list_buckets()["Buckets"]}
    if buckets != {SOURCE_BUCKET}:
        raise BackupError("source bucket inventory changed; review backup coverage")
    before, total = inventory(source, SOURCE_BUCKET)
    if not before:
        raise BackupError("unexpected empty source; refusing empty success")
    manifest = {"format": 1, "source_project": SOURCE_REF, "bucket": SOURCE_BUCKET,
                "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                "scope": "Storage bytes and S3 metadata only; no database or Auth snapshot",
                "files": []}
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz") as archive:
        for key, meta in sorted(before.items()):
            if meta["size"] > MAX_FILE:
                raise BackupError("source file exceeds safety limit")
            response = source.get_object(Bucket=SOURCE_BUCKET, Key=key, IfMatch=meta["etag"])
            data = read_bounded(response, meta["size"])
            if len(data) != meta["size"] or response["ETag"] != meta["etag"]:
                raise BackupError("source changed during download")
            member = "objects/" + hashlib.sha256(key.encode()).hexdigest()
            add_member(archive, member, data)
            manifest["files"].append({"key": key, "member": member, **meta,
                "sha256": hashlib.sha256(data).hexdigest(),
                "content_type": response.get("ContentType", "application/octet-stream"),
                "cache_control": response.get("CacheControl"),
                "metadata": response.get("Metadata", {})})
        after, _ = inventory(source, SOURCE_BUCKET)
        if before != after:
            raise BackupError("source listing changed during backup; no upload performed")
        add_member(archive, "manifest.json", json.dumps(manifest, sort_keys=True).encode())
    payload = buffer.getvalue()
    if len(payload) > MAX_SOURCE + 2 * 1024 * 1024:
        raise BackupError("archive safety limit exceeded")
    verify_archive(payload, manifest)
    return payload, manifest, total


def verify_archive(payload, expected):
    with tarfile.open(fileobj=io.BytesIO(payload), mode="r:gz") as archive:
        members = archive.getmembers()
        expected_names = {"manifest.json"} | {f["member"] for f in expected["files"]}
        if len(members) != len(expected_names) or {m.name for m in members} != expected_names:
            raise BackupError("archive member mismatch")
        if not all(m.isfile() for m in members):
            raise BackupError("archive contains unexpected entries")
        if json.load(archive.extractfile("manifest.json")) != expected:
            raise BackupError("archive manifest mismatch")
        for item in expected["files"]:
            data = archive.extractfile(item["member"]).read(item["size"] + 1)
            if len(data) != item["size"] or hashlib.sha256(data).hexdigest() != item["sha256"]:
                raise BackupError("archive file checksum mismatch")


def transfer(source, destination, snapshot=None):
    # Count all retained objects under the allowed prefix, including partial attempts.
    retained, used = inventory(destination, DEST_BUCKET, PREFIX, MAX_DEST, 10000)
    if snapshot is not None:
        import re
        if not re.fullmatch(r"daily-202610(?:1[0-6])", snapshot):
            raise BackupError("invalid scheduled snapshot")
        base = PREFIX + "file-backups/live/" + snapshot
        if any(key.startswith(base + ".") for key in retained):
            raise BackupError("daily archive already exists; no overwrite or retry")
    payload, manifest, source_bytes = build_snapshot(source)
    if used + len(payload) + 4096 > MAX_DEST:
        raise BackupError("backup storage budget would be exceeded")
    scheduled = snapshot is not None
    snapshot = snapshot or dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex
    base = PREFIX + "file-backups/live/" + snapshot
    digest = hashlib.sha256(payload).hexdigest()
    destination.put_object(Bucket=DEST_BUCKET, Key=base + ".tar.gz", Body=payload,
                           ContentType="application/gzip", ServerSideEncryption="AES256",
                           Metadata={"sha256": digest})
    response = destination.get_object(Bucket=DEST_BUCKET, Key=base + ".tar.gz")
    if response.get("ServerSideEncryption") != "AES256":
        response["Body"].close()
        raise BackupError("destination encryption not confirmed")
    returned = read_bounded(response, len(payload))
    if returned != payload:
        raise BackupError("destination archive differs from source archive")
    verify_archive(returned, manifest)
    result = {"snapshot": snapshot, "files": len(manifest["files"]),
              "source_bytes": source_bytes, "archive_bytes": len(payload), "sha256": digest,
              "storage_round_trip": "passed", "source_listing_stable": True,
              "scheduled_backup_verified": scheduled, "full_application_recovery_verified": False}
    # Completion marker is written only after complete archive readback and member verification.
    destination.put_object(Bucket=DEST_BUCKET, Key=base + ".verified.json",
                           Body=json.dumps(result, sort_keys=True).encode(),
                           ContentType="application/json", ServerSideEncryption="AES256")
    return result


def main(snapshot=None):
    try:
        if os.environ.get("QUESTWELL_LIVE_BACKUP_APPROVED") != "true":
            raise BackupError("live source transfer is not approved")
        required = ["SUPABASE_STORAGE_ACCESS_KEY_ID", "SUPABASE_STORAGE_SECRET_ACCESS_KEY",
                    "B2_KEY_ID", "B2_APPLICATION_KEY"]
        if not all(os.environ.get(key) for key in required):
            raise BackupError("required environment secrets are missing")
        import boto3
        from botocore.config import Config
        config = Config(signature_version="s3v4", connect_timeout=15, read_timeout=60,
                        retries={"total_max_attempts": 1},
                        s3={"addressing_style": "path"},
                        request_checksum_calculation="when_required",
                        response_checksum_validation="when_required")
        source = boto3.client("s3", region_name="us-east-2",
            endpoint_url=f"https://{SOURCE_REF}.storage.supabase.co/storage/v1/s3",
            aws_access_key_id=os.environ[required[0]],
            aws_secret_access_key=os.environ[required[1]], config=config)
        destination = boto3.client("s3", region_name="us-east-005",
            endpoint_url="https://s3.us-east-005.backblazeb2.com",
            aws_access_key_id=os.environ["B2_KEY_ID"],
            aws_secret_access_key=os.environ["B2_APPLICATION_KEY"], config=config)
        result = transfer(source, destination, snapshot=snapshot)
        safe_json = json.dumps(result, sort_keys=True)
        print(safe_json)
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as summary:
                summary.write("Verified Storage backup\n\n```json\n" + safe_json + "\n```\n")
        return 0
    except BackupError as exc:
        print("Storage backup stopped: " + str(exc), file=sys.stderr)
    except Exception:
        # SDK exceptions can contain private object names, IDs or signed request details.
        print("Storage backup stopped: provider or archive error; details withheld", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())

