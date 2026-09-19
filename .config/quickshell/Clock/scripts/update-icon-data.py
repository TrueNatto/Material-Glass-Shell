#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import urllib.request
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
CLOCK_DIR = os.path.dirname(HERE)
SRC_DIR = os.path.join(HERE, ".sources")
EMOJI_SRC = os.path.join(SRC_DIR, "emoji.json")
GLYPH_SRC = os.path.join(SRC_DIR, "glyphnames.json")

EMOJI_URL = "https://raw.githubusercontent.com/iamcal/emoji-data/master/emoji.json"
GLYPH_URL = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json"

EMOJI_OUT = os.path.join(CLOCK_DIR, "data", "emoji-data.json")
GLYPH_OUT = os.path.join(CLOCK_DIR, "data", "nerdfont-icons.json")

CAT_ORDER = [
    "Smileys & Emotion", "People & Body", "Animals & Nature",
    "Food & Drink", "Travel & Places", "Activities",
    "Objects", "Symbols", "Flags",
]
CAT_ALIAS = {
    "Smileys & Emotion": ["emoticon", "face", "mood", "happy"],
    "People & Body": ["hand", "person", "people", "body", "gesture", "finger", "index",
                      "hands", "ear", "nose", "eye", "tooth", "tongue", "lip"],
    "Animals & Nature": ["animal", "nature", "plant", "creature", "bug", "flower", "tree"],
    "Food & Drink": ["food", "drink", "eat", "cooking", "fruit", "dish", "sweet"],
    "Travel & Places": ["travel", "place", "transport", "vehicle", "sky", "water", "building"],
    "Activities": ["activity", "sport", "game", "fun", "music", "celebration"],
    "Objects": ["object", "thing", "tool", "device", "item", "clothing", "clock"],
    "Symbols": ["symbol", "sign", "mark", "heart", "shape", "math", "money"],
    "Flags": ["flag", "country", "nation", "region"],
}
SUB_KW = {
    "cat-face": ["cat", "animal"],
    "monkey-face": ["monkey", "animal"],
    "animal-mammal": ["animal", "mammal"],
    "animal-reptile": ["reptile"],
    "animal-amphibian": ["amphibian"],
    "animal-bird": ["bird"],
    "animal-bug": ["bug", "insect"],
    "animal-marine": ["sea", "marine"],
    "plant-flower": ["flower", "plant"],
    "plant-other": ["plant"],
    "fruit": ["fruit"],
    "vegetable": ["vegetable"],
    "food-prepared": ["food"],
    "drink": ["drink"],
    "person-gesture": ["gesture"],
    "person-resting": ["resting"],
    "person-activity": ["activity"],
    "person-sport": ["sport"],
    "family": ["family"],
    "hand-single-finger": ["finger"],
    "hand-fingers-open": ["hand"],
    "hand-fingers-partial": ["hand"],
    "hand-fingers-closed": ["hand"],
    "body": ["body"],
    "clothing": ["clothing"],
    "transport-ground": ["vehicle"],
    "transport-water": ["boat", "water"],
    "transport-air": ["air", "plane"],
    "transport-sign": ["sign"],
    "money": ["money"],
    "warning": ["warning"],
    "time": ["time", "clock"],
    "flag": ["flag"],
    "flag-subdivision": ["subdivision"],
}
STOP = {
    "a", "an", "the", "and", "or", "with", "of", "for", "in", "on", "at",
    "to", "mother", "father", "parent", "christmas", "claus", "santa",
    "button", "mode", "jack", "suit", "card", "face", "with", "sign",
    "symbols", "symbol", "letters", "letter", "input", "arrows", "arrow",
    "emoji", "software", "every", "possible", "key",
}


def download():
    os.makedirs(SRC_DIR, exist_ok=True)
    for url, path in ((EMOJI_URL, EMOJI_SRC), (GLYPH_URL, GLYPH_SRC)):
        print("downloading", path.split("/")[-1], "...")
        urllib.request.urlretrieve(url, path)
    print("sources saved to", SRC_DIR)


def tok(s):
    return [t for t in re.sub(r"[^a-z0-9 ]", " ", s.lower()).split()
            if t and t not in STOP and len(t) > 1]


def unified_to_char(u):
    return "".join(chr(int(cp, 16)) for cp in u.split("-"))


def build_emoji():
    src = json.load(open(EMOJI_SRC, encoding="utf-8"))
    out, seen = [], set()
    for e in src:
        if e.get("category") == "Component":
            continue
        ch = unified_to_char(e["unified"])
        if not ch or ch in seen:
            continue
        seen.add(ch)
        short = e.get("short_name") or ""
        shorts = e.get("short_names") or []
        sub = e.get("subcategory") or ""
        cat = e.get("category") or "Symbols"
        kws = []
        for s in shorts + [short]:
            if s:
                kws += tok(s)
        kws += tok(e.get("name") or "")
        kws += tok(sub)
        kws += CAT_ALIAS.get(cat, [])
        kws += SUB_KW.get(sub, [])
        out.append({
            "emoji": ch,
            "name": short.replace("_", " ").strip() or (e.get("name") or "").strip(),
            "category": cat,
            "keywords": list(dict.fromkeys(kws)),
        })
    rank = {c: i for i, c in enumerate(CAT_ORDER)}
    out.sort(key=lambda e: (rank.get(e["category"], 99), e["name"]))
    json.dump(out, open(EMOJI_OUT, "w", encoding="utf-8"),
              ensure_ascii=False, separators=(",", ":"))
    print("emoji-data.json:", len(out), "entries;",
          dict(Counter(e["category"] for e in out)))


def build_icons():
    src = json.load(open(GLYPH_SRC, encoding="utf-8"))
    src.pop("METADATA", None)
    out = []
    for name, v in src.items():
        ch = v.get("char")
        if not ch:
            continue
        prefix = name.split("-", 1)[0] if "-" in name and not name.startswith("-") else "nf"
        out.append({
            "icon": ch,
            "name": name,
            "group": prefix,
            "keywords": re.findall(r"[a-z0-9]+", name.lower()),
        })
    out.sort(key=lambda e: (e["group"], e["name"]))
    json.dump(out, open(GLYPH_OUT, "w", encoding="utf-8"),
              ensure_ascii=False, separators=(",", ":"))
    print("nerdfont-icons.json:", len(out), "icons;",
          dict(Counter(e["group"] for e in out)))


if __name__ == "__main__":
    args = sys.argv[1:]
    if "sources" in args:
        download()
    elif "--offline" in args:
        for p in (EMOJI_SRC, GLYPH_SRC):
            if not os.path.exists(p):
                sys.exit("missing source " + p + " - run without --offline first")
    else:
        download()
    build_emoji()
    build_icons()