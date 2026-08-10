#!/usr/bin/env python3
"""Bounded read/glob/grep and count-checked atomic literal replacement."""

from __future__ import annotations

import argparse
import codecs
import json
import os
import re
import stat
import sys
import tempfile
from pathlib import Path


def decode_bytes(data: bytes, requested: str) -> tuple[str, str, bytes]:
    if requested != "auto":
        return data.decode(requested), requested, b""
    for bom, codec in (
        (codecs.BOM_UTF8, "utf-8"),
        (codecs.BOM_UTF16_LE, "utf-16-le"),
        (codecs.BOM_UTF16_BE, "utf-16-be"),
    ):
        if data.startswith(bom):
            return data[len(bom) :].decode(codec), codec, bom
    try:
        return data.decode("utf-8"), "utf-8", b""
    except UnicodeDecodeError:
        return data.decode("gb18030"), "gb18030", b""


def read_text(path: Path, encoding: str) -> tuple[str, str, bytes]:
    return decode_bytes(path.read_bytes(), encoding)


def encode_text(text: str, encoding: str, bom: bytes) -> bytes:
    return bom + text.encode(encoding)


def files_for(root: Path, patterns: list[str]) -> list[Path]:
    resolved_root = root.resolve()
    found: set[Path] = set()
    for pattern in patterns:
        for candidate in resolved_root.glob(pattern):
            if candidate.is_file() and not candidate.is_symlink():
                resolved = candidate.resolve()
                if resolved.is_relative_to(resolved_root):
                    found.add(resolved)
    return sorted(found, key=lambda item: item.as_posix().lower())


def cmd_read(args: argparse.Namespace) -> int:
    path = Path(args.path).resolve()
    text, encoding, _ = read_text(path, args.encoding)
    lines = text.splitlines()
    start = max(1, args.start)
    end = min(len(lines), args.end if args.end is not None else start + 199)
    for number in range(start, end + 1):
        print(f"{number}:{lines[number - 1]}")
    print(json.dumps({"path": str(path), "encoding": encoding, "lines": [start, end]}, ensure_ascii=False), file=sys.stderr)
    return 0


def cmd_glob(args: argparse.Namespace) -> int:
    paths = files_for(Path(args.root), args.pattern)
    for path in paths[: args.max_results]:
        print(path)
    if len(paths) > args.max_results:
        print(f"truncated={len(paths) - args.max_results}", file=sys.stderr)
    return 0


def cmd_grep(args: argparse.Namespace) -> int:
    flags = re.IGNORECASE if args.ignore_case else 0
    regex = re.compile(args.pattern, flags)
    matches = 0
    for path in files_for(Path(args.root), args.glob):
        try:
            text, _, _ = read_text(path, args.encoding)
        except (UnicodeDecodeError, OSError):
            continue
        for line_number, line in enumerate(text.splitlines(), 1):
            if regex.search(line):
                print(f"{path}:{line_number}:{line}")
                matches += 1
                if matches >= args.max_results:
                    return 0
    return 0 if matches else 1


def atomic_write(path: Path, payload: bytes, mode: int) -> None:
    temporary_name = ""
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, prefix=f".{path.name}.", suffix=".wanan", delete=False) as handle:
            temporary_name = handle.name
            handle.write(payload)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary_name, stat.S_IMODE(mode))
        os.replace(temporary_name, path)
    finally:
        if temporary_name and os.path.exists(temporary_name):
            os.unlink(temporary_name)


def cmd_replace(args: argparse.Namespace) -> int:
    if args.old == args.new:
        raise ValueError("old and new text are identical")
    plans: list[tuple[Path, str, str, bytes, int, int]] = []
    total = 0
    for path in files_for(Path(args.root), args.glob):
        text, encoding, bom = read_text(path, args.encoding)
        count = text.count(args.old)
        if count:
            plans.append((path, text, encoding, bom, path.stat().st_mode, count))
            total += count
            print(f"{path}\tmatches={count}")
    print(json.dumps({"files": len(plans), "matches": total, "apply": args.apply}, ensure_ascii=False))
    if not args.apply:
        return 0
    if args.expected is None:
        raise ValueError("--expected is required with --apply")
    if total != args.expected:
        raise ValueError(f"expected {args.expected} matches but found {total}; nothing changed")
    if total == 0:
        raise ValueError("refusing to apply a zero-match replacement")
    for path, text, encoding, bom, mode, _ in plans:
        atomic_write(path, encode_text(text.replace(args.old, args.new), encoding, bom), mode)
    return 0


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser()
    commands = root.add_subparsers(dest="command", required=True)

    read = commands.add_parser("read")
    read.add_argument("--path", required=True)
    read.add_argument("--start", type=int, default=1)
    read.add_argument("--end", type=int)
    read.add_argument("--encoding", default="auto")
    read.set_defaults(handler=cmd_read)

    glob = commands.add_parser("glob")
    glob.add_argument("--root", required=True)
    glob.add_argument("--pattern", action="append", required=True)
    glob.add_argument("--max-results", type=int, default=1000)
    glob.set_defaults(handler=cmd_glob)

    grep = commands.add_parser("grep")
    grep.add_argument("--root", required=True)
    grep.add_argument("--glob", action="append", default=[])
    grep.add_argument("--pattern", required=True)
    grep.add_argument("--encoding", default="auto")
    grep.add_argument("--ignore-case", action="store_true")
    grep.add_argument("--max-results", type=int, default=1000)
    grep.set_defaults(handler=cmd_grep)

    replace = commands.add_parser("replace")
    replace.add_argument("--root", required=True)
    replace.add_argument("--glob", action="append", required=True)
    replace.add_argument("--old", required=True)
    replace.add_argument("--new", required=True)
    replace.add_argument("--encoding", default="auto")
    replace.add_argument("--expected", type=int)
    replace.add_argument("--apply", action="store_true")
    replace.set_defaults(handler=cmd_replace)
    return root


def main() -> int:
    args = parser().parse_args()
    if args.command == "grep" and not args.glob:
        args.glob = ["**/*"]
    try:
        return args.handler(args)
    except (OSError, UnicodeError, ValueError, re.error) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
