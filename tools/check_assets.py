#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def norm(p: str) -> str:
    return p.replace("\\", "/").lower()

assets = set()
for p in (ROOT / "assets").rglob("*"):
    if p.is_file():
        assets.add(norm(str(p.relative_to(ROOT))))

refs = set()

pat = re.compile(r"""['"](assets/[^'"]+)['"]""")

for p in (ROOT / "lib").rglob("*.dart"):
    text = p.read_text(encoding="utf-8", errors="ignore")
    for m in pat.findall(text):
        refs.add(norm(m))

for p in (ROOT / "assets" / "data").rglob("*.json"):
    text = p.read_text(encoding="utf-8", errors="ignore")
    for m in pat.findall(text):
        refs.add(norm(m))

# pubspec font paths
pub = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
for m in re.findall(r"asset:\s*(assets/[^\s]+)", pub):
    refs.add(norm(m))

missing = sorted(r for r in refs if r not in assets)

print("=== REFERANS VAR, DOSYA YOK ===")
for r in missing:
    print(r)

# Tarot JSON images
print("\n=== TAROT JSON (eksik gorseller) ===")
for jf in ["assets/data/turk_tarotu.json", "assets/data/turk_tarotu_full.json"]:
    path = ROOT / jf
    if not path.exists():
        continue
    data = json.loads(path.read_text(encoding="utf-8"))
    items = data if isinstance(data, list) else []
    if isinstance(data, dict):
        items = list(data.get("cards", [])) + list(data.get("spreads", []))
    for c in items:
        img = c.get("image", "")
        if img and norm(img) not in assets:
            print(f"  [{jf}] {img}")

# Takvim DB eski uzantilar (kod webp kullaniyor - OK)
print("\n=== TAKVIM veritabani.json simge_resmi (eski uzanti, kod .webp kullanir) ===")
tv_path = ROOT / "assets/data/takvim_veritabani.json"
if tv_path.exists():
    tv = json.loads(tv_path.read_text(encoding="utf-8"))
    for item in tv:
        s = item.get("simge_resmi", "")
        stem = Path(s).stem
        webp = norm(f"assets/images/{stem}.webp")
        old = norm(f"assets/images/{s}")
        if webp in assets:
            if s != f"{stem}.webp":
                print(f"  UYARI: JSON '{s}' -> kod '{stem}.webp' (mevcut)")
        elif old not in assets:
            print(f"  EKSIK: {s} (webp de yok: {stem}.webp)")

# Unused images (sample - images never referenced)
print("\n=== KULLANILMAYAN GORSELLER (ornek, lib+data disinda) ===")
image_assets = {a for a in assets if "/images/" in a and a.endswith((".webp", ".png", ".jpeg", ".jpg"))}
referenced_images = {r for r in refs if "/images/" in r}
unused = sorted(image_assets - referenced_images)
for u in unused[:40]:
    print(f"  {u}")
if len(unused) > 40:
    print(f"  ... ve {len(unused)-40} tane daha")

print("\n=== PUBSPEC KLASORLERI ===")
for d in ["assets/fonts", "assets/onboarding", "assets/audio"]:
    p = ROOT / d
    n = len(list(p.rglob("*"))) if p.exists() else -1
    print(f"  {d}: {'YOK' if not p.exists() else f'{n} dosya'}")
