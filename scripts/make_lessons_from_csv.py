#!/usr/bin/env python3
"""Bulk import CSV -> lesson JSON files, optionally update index.json.

Usage:
  python3 scripts/make_lessons_from_csv.py lessons.csv --out JapaneseBuddy/Resources/lessons --index

CSV columns:
  id,title,canDo,shadow1,shadow2,shadow3,shadow4,
  listQ,A,B,C,lAns,readQ,choices,rAns,kanji,reading,meaning

The `choices`, `kanji`, `reading`, `meaning` fields use '|' separators.
"""
from __future__ import annotations
import argparse
import csv
import json
from pathlib import Path


def write_lesson(row: dict, out_dir: Path) -> str:
    lesson = {
        "id": row["id"],
        "title": row["title"],
        "canDo": row["canDo"],
        "activities": [],
        "tips": [],
        "kanjiWords": [],
    }
    lesson["activities"].append({"objective": {"text": row["canDo"]}})
    segs = [row.get(f"shadow{i}", "") for i in range(1, 5)]
    segs = [s for s in segs if s]
    lesson["activities"].append({"shadow": {"segments": segs}})
    listen_choices = [row.get("A", ""), row.get("B", ""), row.get("C", "")]
    lesson["activities"].append({
        "listening": {
            "prompt": row["listQ"],
            "choices": listen_choices,
            "answer": max(int(row.get("lAns", 0)) - 1, 0),
        }
    })
    read_choices = row["choices"].split("|") if row.get("choices") else []
    lesson["activities"].append({
        "reading": {
            "prompt": row["readQ"],
            "items": read_choices,
            "answer": max(int(row.get("rAns", 0)) - 1, 0),
        }
    })
    lesson["activities"].append({"check": {}})
    kanji = row.get("kanji", "").split("|")
    reading = row.get("reading", "").split("|")
    meaning = row.get("meaning", "").split("|")
    for k, r, m in zip(kanji, reading, meaning):
        if k and r and m:
            lesson["kanjiWords"].append({
                "id": f"{row['id']}-{k}",
                "kanji": k,
                "reading": r,
                "meaning": m,
            })
    name = f"{row['id']}-{row['title'].replace(' ', '').replace('&', '')}.json"
    out_path = out_dir / name
    out_path.write_text(json.dumps(lesson, ensure_ascii=False, indent=2))
    return name


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("csv", type=Path, help="Input CSV file")
    ap.add_argument("--out", type=Path, default=Path(__file__).resolve().parents[1] / "JapaneseBuddy/Resources/lessons",
                    help="Output directory for JSON lessons")
    ap.add_argument("--index", action="store_true", help="Also write index.json in order of CSV rows")
    args = ap.parse_args()

    rows = list(csv.DictReader(args.csv.read_text().splitlines()))
    args.out.mkdir(parents=True, exist_ok=True)
    ids = []
    for row in rows:
        ids.append(row["id"])
        name = write_lesson(row, args.out)
        print(f"Wrote {args.out / name}")
    if args.index:
        (args.out / "index.json").write_text(json.dumps(ids, ensure_ascii=False, indent=2))
        print(f"Wrote {args.out / 'index.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

