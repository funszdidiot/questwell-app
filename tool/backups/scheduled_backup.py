"""Seven-date authorization boundary; no automatic catch-up or manual copying."""
import datetime as dt
import os
import sys
import storage_backup

START = dt.date(2026, 10, 10)
END = dt.date(2026, 10, 16)


def permitted_snapshot(env, now):
    if now.tzinfo is None:
        raise ValueError("timezone-aware clock required")
    now = now.astimezone(dt.timezone.utc)
    checks = {
        "GITHUB_REPOSITORY": "funszdidiot/questwell-app",
        "GITHUB_REF": "refs/heads/flutterflow",
        "GITHUB_EVENT_NAME": "schedule",
        "GITHUB_RUN_ATTEMPT": "1",
        "QUESTWELL_SCHEDULED_BACKUP_APPROVED": "true",
    }
    if any(env.get(key) != value for key, value in checks.items()):
        return None
    if not START <= now.date() <= END or now.time() < dt.time(7, 23):
        return None
    return "daily-" + now.strftime("%Y%m%d")


def main():
    snapshot = permitted_snapshot(os.environ, dt.datetime.now(dt.timezone.utc))
    if snapshot is None:
        print("Scheduled copy not permitted: event, date, attempt or enable gate.")
        return 1
    os.environ["QUESTWELL_LIVE_BACKUP_APPROVED"] = "true"
    return storage_backup.main(snapshot=snapshot)


if __name__ == "__main__":
    sys.exit(main())
