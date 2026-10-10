import hashlib
import json
import unittest
import urllib.parse
import b2_connection_check as b2


class FakeB2:
    def __init__(self, corrupt=False):
        self.calls = []
        self.corrupt = corrupt
        self.scope = {"buckets": [{"id": b2.BUCKET_ID}], "namePrefix": b2.PREFIX,
                      "capabilities": ["readFiles", "writeFiles"]}

    def __call__(self, url, token, data=None, headers=None, limit=65536):
        self.calls.append(url)
        if "b2_authorize_account" in url:
            result = {"authorizationToken": "test-token", "apiInfo": {"storageApi": {
                "allowed": self.scope, "apiUrl": "https://api005.backblazeb2.com",
                "downloadUrl": "https://f005.backblazeb2.com"}}}
        elif "b2_get_upload_url" in url:
            result = {"bucketId": b2.BUCKET_ID, "uploadUrl": "https://pod-test.backblaze.com/upload",
                      "authorizationToken": "test-upload-token"}
        elif url.endswith("/upload"):
            self.payload = data
            result = {"bucketId": b2.BUCKET_ID, "fileId": "synthetic-id",
                      "fileName": urllib.parse.unquote(headers["X-Bz-File-Name"]),
                      "contentLength": len(data), "contentSha1": hashlib.sha1(data).hexdigest(),
                      "serverSideEncryption": {"mode": "SSE-B2", "algorithm": "AES256"}}
        elif "b2_download_file_by_id" in url:
            return b"corrupt" if self.corrupt else self.payload
        else:
            raise AssertionError("unexpected operation")
        return json.dumps(result).encode()


class ConnectionTests(unittest.TestCase):
    env = {"B2_KEY_ID": "test-id", "B2_APPLICATION_KEY": "test-secret"}

    def test_round_trip_and_scope(self):
        fake = FakeB2()
        result = b2.run(self.env, fake)
        self.assertEqual(len(fake.calls), 4)
        self.assertEqual(result["sha256"], hashlib.sha256(fake.payload).hexdigest())
        self.assertLess(result["bytes"], 1024)
        self.assertTrue(result["object"].startswith("questwell/connection-checks/"))
        self.assertFalse(result["scheduled_backup_verified"])
        self.assertNotIn("test-secret", json.dumps(result))

    def test_reject_corrupt_download(self):
        with self.assertRaisesRegex(b2.CheckFailed, "bytes differ"):
            b2.run(self.env, FakeB2(corrupt=True))

    def test_reject_missing_secrets_without_network(self):
        fake = FakeB2()
        with self.assertRaises(b2.CheckFailed):
            b2.run({}, fake)
        self.assertEqual(fake.calls, [])

    def test_reject_broad_or_wrong_scope_before_upload(self):
        for update in ({"buckets": None}, {"buckets": [{"id": "other"}]},
                       {"namePrefix": None}, {"capabilities": ["writeFiles"]}):
            with self.subTest(update=update):
                fake = FakeB2()
                fake.scope.update(update)
                with self.assertRaises(b2.CheckFailed):
                    b2.run(self.env, fake)
                self.assertEqual(len(fake.calls), 1)

    def test_reject_untrusted_endpoints(self):
        for url in ("http://api.backblazeb2.com", "https://backblazeb2.com.evil.test",
                    "https://evilbackblazeb2.com", "https://user@api.backblazeb2.com",
                    "https://api.backblazeb2.com:8443"):
            with self.subTest(url=url), self.assertRaises(b2.CheckFailed):
                b2.validate_url(url)

    def test_reject_redirect(self):
        with self.assertRaises(b2.CheckFailed):
            b2.NoRedirect().redirect_request(None, None, 302, "", {}, "https://evil.test")

    def test_unique_objects(self):
        self.assertNotEqual(b2.run(self.env, FakeB2())["object"],
                            b2.run(self.env, FakeB2())["object"])


if __name__ == "__main__":
    unittest.main()
