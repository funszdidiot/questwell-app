"""One synthetic B2 round trip. No source access, scheduling or deletion."""
import base64
import hashlib
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid

BUCKET_ID = "6cfcb091f5b02b0da31c0212"
BUCKET_NAME = "questwell-backups-20261009"
PREFIX = "questwell/"


class CheckFailed(Exception):
    pass


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise CheckFailed("redirect rejected")


def validate_url(url):
    parsed = urllib.parse.urlsplit(url)
    host = parsed.hostname or ""
    if (parsed.scheme != "https" or parsed.username or parsed.password
            or parsed.port not in (None, 443) or parsed.fragment
            or not any(host.endswith("." + d) for d in ("backblazeb2.com", "backblaze.com"))):
        raise CheckFailed("unexpected B2 endpoint")
    return url


def request(url, token, data=None, headers=None, limit=65536):
    validate_url(url)
    req = urllib.request.Request(url, data=data, headers={
        "Authorization": token, **(headers or {})})
    # No redirect can forward authorization to another destination.
    with urllib.request.build_opener(NoRedirect()).open(req, timeout=30) as response:
        result = response.read(limit + 1)
    if len(result) > limit:
        raise CheckFailed("response exceeds size limit")
    return result


def check_scope(storage):
    allowed = storage["allowed"]
    buckets = allowed.get("buckets")
    if not isinstance(buckets, list) or len(buckets) != 1 or buckets[0].get("id") != BUCKET_ID:
        raise CheckFailed("key must be restricted to the backup bucket")
    if allowed.get("namePrefix") != PREFIX:
        raise CheckFailed("key must be restricted to questwell/ prefix")
    if not {"readFiles", "writeFiles"}.issubset(allowed.get("capabilities", [])):
        raise CheckFailed("key needs file read and write capabilities")


def run(env, transport=request):
    key_id = env.get("B2_KEY_ID", "")
    key = env.get("B2_APPLICATION_KEY", "")
    if not key_id or not key:
        raise CheckFailed("required B2 environment secrets are missing")
    basic = "Basic " + base64.b64encode(f"{key_id}:{key}".encode()).decode()
    print("B2 stage: authorize saved key", flush=True)
    auth = json.loads(transport("https://api.backblazeb2.com/b2api/v4/b2_authorize_account", basic))
    storage = auth["apiInfo"]["storageApi"]
    check_scope(storage)
    api = validate_url(storage["apiUrl"])
    download = validate_url(storage["downloadUrl"])
    token = auth["authorizationToken"]
    print("B2 stage: get upload URL (key authorization and scope passed)", flush=True)
    upload = json.loads(transport(api + "/b2api/v4/b2_get_upload_url?" +
                                 urllib.parse.urlencode({"bucketId": BUCKET_ID}), token))
    if upload["bucketId"] != BUCKET_ID:
        raise CheckFailed("upload bucket mismatch")
    validate_url(upload["uploadUrl"])
    name = PREFIX + "connection-checks/" + uuid.uuid4().hex + ".json"
    payload = json.dumps({"purpose": "Questwell synthetic backup connection check",
                          "nonce": uuid.uuid4().hex}, sort_keys=True).encode() + b"\n"
    sha1 = hashlib.sha1(payload).hexdigest()
    print("B2 stage: upload synthetic object", flush=True)
    stored = json.loads(transport(upload["uploadUrl"], upload["authorizationToken"], payload, {
        "X-Bz-File-Name": urllib.parse.quote(name, safe="/"),
        "Content-Type": "application/json", "Content-Length": str(len(payload)),
        "X-Bz-Content-Sha1": sha1, "X-Bz-Server-Side-Encryption": "AES256"}))
    if (stored["bucketId"] != BUCKET_ID or stored["fileName"] != name
            or stored["contentLength"] != len(payload) or stored["contentSha1"] != sha1):
        raise CheckFailed("upload metadata mismatch")
    encryption = stored.get("serverSideEncryption") or {}
    if encryption.get("mode") != "SSE-B2" or encryption.get("algorithm") != "AES256":
        raise CheckFailed("upload encryption not confirmed")
    print("B2 stage: download and compare synthetic object", flush=True)
    restored = transport(download + "/b2api/v4/b2_download_file_by_id?" +
                         urllib.parse.urlencode({"fileId": stored["fileId"]}), token,
                         limit=len(payload))
    if restored != payload:
        raise CheckFailed("download bytes differ from upload")
    return {"connection_check": "passed", "bucket": BUCKET_NAME, "object": name,
            "bytes": len(payload), "sha256": hashlib.sha256(restored).hexdigest(),
            "encryption": "SSE-B2 AES256", "synthetic_only": True,
            "scheduled_backup_verified": False, "object_retained": True}


def main():
    try:
        result = run(os.environ)
    except CheckFailed as exc:
        print("B2 check failed: " + str(exc), file=sys.stderr)
        return 1
    except urllib.error.HTTPError as exc:
        print(f"B2 check failed: HTTP {exc.code}; response body withheld", file=sys.stderr)
        return 1
    except Exception:
        # Provider response/error strings can contain tokens or signed endpoints.
        print("B2 check failed: network or response error; details withheld", file=sys.stderr)
        return 1
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
