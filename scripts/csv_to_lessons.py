#!/usr/bin/env python3
"""Convert lesson rows in CSV to individual JSON files.

CSV columns:
  id,title,canDo,shadow1,shadow2,shadow3,shadow4,
  listQ,A,B,C,lAns,readQ,choices,rAns,kanji,reading,meaning

`choices`, `kanji`, `reading`, and `meaning` use `|` to separate values.
Outputs JSON files under `JapaneseBuddy/Resources/lessons/`.
"""
from __future__ import annotations
import csv
import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: csv_to_lessons.py input.csv", file=sys.stderr)
        return 1
    src = Path(sys.argv[1])
    out_dir = Path(__file__).resolve().parents[1] / "JapaneseBuddy/Resources/lessons"
    rows = csv.DictReader(src.read_text().splitlines())
    for row in rows:
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
        print(f"Wrote {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
