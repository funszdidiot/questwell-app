"""Dedicated staging archive entrypoint. No Apple delivery capability."""

from tool.ci.ios_testflight import main


if __name__ == "__main__":
    raise SystemExit(main("staging"))
