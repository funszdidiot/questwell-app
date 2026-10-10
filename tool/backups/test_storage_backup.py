import datetime as dt
import io
import unittest
from unittest.mock import patch
import storage_backup as b


class Source:
    def __init__(self, changed=False):
        self.list_count = 0
        self.changed = changed
    def list_buckets(self):
        return {"Buckets": [{"Name": b.SOURCE_BUCKET}]}
    def list_objects_v2(self, **kwargs):
        self.list_count += 1
        return {"Contents": [{"Key": "private-owner/file.jpg", "Size": 4,
            "ETag": '"changed"' if self.changed and self.list_count > 1 else '"original"',
            "LastModified": dt.datetime(2026, 10, 10, tzinfo=dt.timezone.utc)}]}
    def get_object(self, **kwargs):
        assert kwargs["IfMatch"] == '"original"'
        return {"Body": io.BytesIO(b"data"), "ETag": '"original"', "ContentType": "image/jpeg"}


class Destination:
    def __init__(self, corrupt=False, used=0):
        self.objects = {}
        self.corrupt, self.used = corrupt, used
    def list_objects_v2(self, **kwargs):
        return {"Contents": [{"Key": "questwell/old", "Size": self.used, "ETag": "old",
                              "LastModified": dt.datetime(2026, 10, 9)}]}
    def put_object(self, **kwargs):
        self.objects[kwargs["Key"]] = kwargs["Body"]
        assert kwargs["ServerSideEncryption"] == "AES256"
    def get_object(self, **kwargs):
        data = b"corrupt" if self.corrupt else self.objects[kwargs["Key"]]
        return {"Body": io.BytesIO(data), "ServerSideEncryption": "AES256"}


class StorageTests(unittest.TestCase):
    def test_verified_round_trip(self):
        dest = Destination()
        result = b.transfer(Source(), dest)
        self.assertEqual(result["files"], 1)
        self.assertEqual(result["source_bytes"], 4)
        self.assertEqual(len(dest.objects), 2)
        self.assertFalse(result["scheduled_backup_verified"])
        self.assertNotIn("private-owner", str(result))

    def test_changed_source_never_uploads(self):
        dest = Destination()
        with self.assertRaisesRegex(b.BackupError, "listing changed"):
            b.transfer(Source(changed=True), dest)
        self.assertEqual(dest.objects, {})

    def test_corrupt_readback_no_verified_marker(self):
        dest = Destination(corrupt=True)
        with self.assertRaisesRegex(b.BackupError, "differs"):
            b.transfer(Source(), dest)
        self.assertEqual(len(dest.objects), 1)
        self.assertFalse(any(k.endswith(".verified.json") for k in dest.objects))

    def test_storage_cap_no_write(self):
        dest = Destination(used=b.MAX_DEST)
        with self.assertRaisesRegex(b.BackupError, "budget"):
            b.transfer(Source(), dest)
        self.assertEqual(dest.objects, {})

    def test_new_bucket_requires_coverage_review(self):
        source = Source()
        source.list_buckets = lambda: {"Buckets": [{"Name": b.SOURCE_BUCKET}, {"Name": "new"}]}
        with self.assertRaisesRegex(b.BackupError, "coverage"):
            b.build_snapshot(source)

    def test_incomplete_pagination_rejected(self):
        source = Source()
        source.list_objects_v2 = lambda **kw: {"IsTruncated": True}
        with self.assertRaisesRegex(b.BackupError, "incomplete"):
            b.inventory(source, b.SOURCE_BUCKET)

    def test_pagination_covers_all_pages(self):
        source = Source()
        pages = iter([{"IsTruncated": True, "NextContinuationToken": "next"},
                      source.list_objects_v2()])
        source.list_objects_v2 = lambda **kw: next(pages)
        found, size = b.inventory(source, b.SOURCE_BUCKET)
        self.assertEqual((len(found), size), (1, 4))

    def test_approval_required_before_import_or_network(self):
        with patch.dict(b.os.environ, {}, clear=True):
            self.assertEqual(b.main(), 1)


if __name__ == "__main__":
    unittest.main()
