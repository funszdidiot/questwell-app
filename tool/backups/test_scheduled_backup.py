import datetime as dt
import unittest
from unittest.mock import patch
import scheduled_backup as s
import storage_backup as b
from test_storage_backup import Source, Destination


class ScheduleTests(unittest.TestCase):
    def setUp(self):
        self.env = {"GITHUB_REPOSITORY": "funszdidiot/questwell-app",
                    "GITHUB_REF": "refs/heads/flutterflow",
                    "GITHUB_EVENT_NAME": "schedule", "GITHUB_RUN_ATTEMPT": "1",
                    "QUESTWELL_SCHEDULED_BACKUP_APPROVED": "true"}

    def test_exact_seven_dates_and_time(self):
        accepted = []
        for day in range(1, 25):
            now = dt.datetime(2026, 10, day, 7, 23, tzinfo=dt.timezone.utc)
            if s.permitted_snapshot(self.env, now):
                accepted.append(day)
        self.assertEqual(accepted, list(range(10, 17)))
        self.assertIsNone(s.permitted_snapshot(self.env, dt.datetime(2026, 10, 10, 7, 22, tzinfo=dt.timezone.utc)))
        self.assertIsNone(s.permitted_snapshot(self.env, dt.datetime(2027, 10, 10, 8, tzinfo=dt.timezone.utc)))

    def test_no_manual_push_rerun_or_other_branch(self):
        now = dt.datetime(2026, 10, 11, 8, tzinfo=dt.timezone.utc)
        for key, value in [("GITHUB_EVENT_NAME", "workflow_dispatch"),
                           ("GITHUB_EVENT_NAME", "push"), ("GITHUB_RUN_ATTEMPT", "2"),
                           ("GITHUB_REF", "refs/heads/questwell-dev"),
                           ("GITHUB_REPOSITORY", "other/repo"),
                           ("QUESTWELL_SCHEDULED_BACKUP_APPROVED", "false")]:
            with self.subTest(key=key, value=value):
                self.assertIsNone(s.permitted_snapshot({**self.env, key: value}, now))

    def test_existing_or_partial_daily_archive_never_reads_source(self):
        for suffix in [".tar.gz", ".verified.json"]:
            dest = Destination()
            dest.list_objects_v2 = lambda **kw: {"Contents": [{
                "Key": b.PREFIX + "file-backups/live/daily-20261010" + suffix,
                "Size": 1, "ETag": "x", "LastModified": dt.datetime(2026, 10, 10)}]}
            source = Source()
            with self.assertRaisesRegex(b.BackupError, "already exists"):
                b.transfer(source, dest, snapshot="daily-20261010")
            self.assertEqual(source.list_count, 0)
            self.assertEqual(dest.objects, {})

    def test_scheduled_round_trip(self):
        result = b.transfer(Source(), Destination(), snapshot="daily-20261010")
        self.assertTrue(result["scheduled_backup_verified"])
        self.assertEqual(result["snapshot"], "daily-20261010")

    def test_rejected_execution_never_invokes_transfer(self):
        with patch.dict(s.os.environ, {}, clear=True), patch.object(b, "main") as transfer:
            self.assertEqual(s.main(), 1)
            transfer.assert_not_called()


if __name__ == "__main__":
    unittest.main()
