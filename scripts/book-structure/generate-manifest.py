#!/usr/bin/env python3
"""Generate manifest.yaml — 60 files, chapters 01-58 + front matter."""
import yaml
from pathlib import Path

OUT = Path(__file__).resolve().parent / "manifest.yaml"

# (legacy, new_file, chapter, part, title, slug, parable?)
RAW = [
    ("0.md", "00-title.md", None, None, "Title / Copyright / Preface", "title"),
    ("000.md", "00-toc.md", None, None, "Table of Contents", "toc"),
    ("001.md", "01-warriors-facing-dragons.md", 1, "I Foundation", "Warriors Facing Dragons", "warriors-facing-dragons"),
    ("002.md", "02-crisis-resources.md", 2, "I Foundation", "Crisis Resources and Safety Protocols", "crisis-resources"),
    ("003.md", "03-chapter-sequencing-guide.md", 3, "I Foundation", "Chapter Sequencing Guide", "chapter-sequencing-guide"),
    ("062.md", "04-transitions.md", 4, "II Parables", "Transitions", "transitions"),
    ("004.md", "05-reluctant-student.md", 5, "II Parables", "The Reluctant Student", "reluctant-student", True),
    ("005.md", "06-grandfather-speaks-of-worth.md", 6, "II Parables", "The Grandfather Speaks of Worth", "grandfather-speaks-of-worth", True),
    ("006.md", "07-unheard-boy.md", 7, "II Parables", "The Unheard Boy", "unheard-boy", True),
    ("007.md", "08-respect-gateway.md", 8, "II Parables", "Respect: The Gateway to the Dragon", "respect-gateway", True),
    ("009.md", "09-real-nature-of-dragon.md", 9, "II Parables", "The Real Nature of the Dragon", "real-nature-of-dragon", True),
    ("010.md", "10-dragon-wounded-pride.md", 10, "II Parables", "The Dragon of Wounded Pride", "dragon-wounded-pride", True),
    ("011.md", "11-what-it-means-to-face.md", 11, "II Parables", "What It Means to Face the Dragon", "what-it-means-to-face", True),
    ("012.md", "12-fire-inside.md", 12, "II Parables", "The Fire Inside", "fire-inside", True),
    ("015.md", "13-unseen-wound.md", 13, "II Parables", "The Unseen Wound", "unseen-wound", True),
    ("016.md", "14-wounded-bear.md", 14, "II Parables", "The Wounded Bear", "wounded-bear", True),
    ("017.md", "15-chained-giant.md", 15, "II Parables", "The Chained Giant", "chained-giant", True),
    ("018.md", "16-shattered-helmet.md", 16, "II Parables", "The Shattered Helmet", "shattered-helmet", True),
    ("019.md", "17-warrior-could-not-cry.md", 17, "II Parables", "The Warrior Who Could Not Cry", "warrior-could-not-cry", True),
    ("020.md", "18-lion-feared-roar.md", 18, "II Parables", "The Lion Who Feared His Roar", "lion-feared-roar", True),
    ("021.md", "19-two-wolves-river.md", 19, "II Parables", "The Two Wolves by the River", "two-wolves-river", True),
    ("022.md", "20-three-rivers.md", 20, "II Parables", "The Three Rivers", "three-rivers", True),
    ("023.md", "21-empty-quiver.md", 21, "II Parables", "The Empty Quiver", "empty-quiver", True),
    ("024.md", "22-unfinished-mask.md", 22, "II Parables", "The Unfinished Mask", "unfinished-mask", True),
    ("025.md", "23-seven-doors.md", 23, "II Parables", "The Seven Doors", "seven-doors", True),
    ("026.md", "24-test-six-mirrors.md", 24, "II Parables", "The Test of the Six Mirrors", "test-six-mirrors", True),
    ("027.md", "25-warrior-walked-backward.md", 25, "II Parables", "The Warrior Who Walked Backward", "warrior-walked-backward", True),
    ("028.md", "26-warrior-chased-shadows.md", 26, "II Parables", "The Warrior Who Chased Every Shadow", "warrior-chased-shadows", True),
    ("029.md", "27-anvil-and-sword.md", 27, "II Parables", "The Anvil and the Sword", "anvil-and-sword", True),
    ("030.md", "28-blacksmiths-tongs.md", 28, "II Parables", "The Blacksmith's Tongs", "blacksmiths-tongs", True),
    ("031.md", "29-silent-stone.md", 29, "II Parables", "The Silent Stone", "silent-stone", True),
    ("032.md", "30-thornling-tree.md", 30, "II Parables", "The Thornling Tree", "thornling-tree", True),
    ("033.md", "31-haunted-blade.md", 31, "II Parables", "The Haunted Blade", "haunted-blade", True),
    ("034.md", "32-masterless-horse.md", 32, "II Parables", "The Masterless Horse", "masterless-horse", True),
    ("035.md", "33-broken-drum.md", 33, "II Parables", "The Broken Drum", "broken-drum", True),
    ("036.md", "34-lamp-no-oil.md", 34, "II Parables", "The Lamp with No Oil", "lamp-no-oil", True),
    ("037.md", "35-echoing-cave.md", 35, "II Parables", "The Echoing Cave", "echoing-cave", True),
    ("039.md", "36-open-hand.md", 36, "II Parables", "The Open Hand", "open-hand", True),
    ("040.md", "37-waterfall.md", 37, "II Parables", "The Waterfall", "waterfall", True),
    ("041.md", "38-spear-two-points.md", 38, "II Parables", "The Spear with Two Points", "spear-two-points", True),
    ("042.md", "39-hunter-never-missed.md", 39, "II Parables", "The Hunter Who Never Missed", "hunter-never-missed", True),
    ("043.md", "40-final-bow-before-battle.md", 40, "II Parables", "The Final Bow Before Battle", "final-bow-before-battle", True),
    ("046.md", "41-ask-for-help.md", 41, "II Parables", "The Warrior Who Learned to Ask for Help", "ask-for-help", True),
    ("047.md", "42-forgave-his-father.md", 42, "II Parables", "The Man Who Forgave His Father", "forgave-his-father", True),
    ("049.md", "43-broke-the-cycle.md", 43, "II Parables", "The Man Who Broke the Cycle with His Children", "broke-the-cycle", True),
    ("050.md", "44-purpose-beyond-survival.md", 44, "II Parables", "The Warrior Who Found Purpose Beyond Survival", "purpose-beyond-survival", True),
    ("054.md", "45-grandfathers-confession.md", 45, "II Parables", "The Grandfather's Confession", "grandfathers-confession", True),
    ("055.md", "46-fire-embers.md", 46, "II Parables", "The Fire Embers", "fire-embers", True),
    ("061.md", "47-parable-summary.md", 47, "II Parables", "Summary of Parables and Core Principles", "parable-summary"),
    ("060.md", "48-discarded-heart.md", 48, "III Patterns", "The Discarded Heart (Patterns)", "discarded-heart"),
    ("063.md", "49-self-destruction-to-compassion.md", 49, "IV Worksheets", "From Self-Destruction to Self-Compassion", "self-destruction-to-compassion"),
    ("066.md", "50-writing-your-life.md", 50, "V Workbook", "Writing Your Life", "writing-your-life"),
    ("064.md", "51-practical-tools.md", 51, "VI Tools", "Additional Practical Tools", "practical-tools"),
    ("065.md", "52-progress-tracking.md", 52, "VI Tools", "Progress Tracking Tools", "progress-tracking"),
    ("067.md", "53-guides-and-resources.md", 53, "VI Tools", "Guides and Resources", "guides-and-resources"),
    ("068.md", "54-quick-reference.md", 54, "Appendices", "Quick Reference Guide", "quick-reference"),
    ("069.md", "55-glossary.md", 55, "Appendices", "Glossary and Index", "glossary"),
    ("__CREATE__", "56-bridge-to-actualization.md", 56, "Appendices", "Bridge to Actualization", "bridge-to-actualization"),
    ("071.md", "57-actualization.md", 57, "Appendices", "Actualization", "actualization"),
    ("070.md", "58-final-conclusion.md", 58, "Appendices", "Final Conclusion", "final-conclusion"),
]

files = []
for entry in RAW:
    legacy, new_file, chapter, part, title, slug = entry[:6]
    parable = entry[6] if len(entry) > 6 else False
    rec = {
        "legacy": None if legacy == "__CREATE__" else legacy,
        "create": legacy == "__CREATE__",
        "new_file": new_file,
        "chapter": chapter,
        "part": part,
        "title": title,
        "slug": slug,
    }
    if parable:
        rec["parable"] = True
    files.append(rec)

for i, rec in enumerate(files):
    prev_rec = files[i - 1] if i > 0 else None
    next_rec = files[i + 1] if i < len(files) - 1 else None
    rec["nav_prev"] = prev_rec["new_file"] if prev_rec else None
    rec["nav_next"] = next_rec["new_file"] if next_rec else None
    if prev_rec:
        ch = prev_rec.get("chapter")
        rec["nav_prev_label"] = (
            f"Chapter {ch} — {prev_rec['title']}" if ch else prev_rec["title"]
        )
    else:
        rec["nav_prev_label"] = None
    if next_rec:
        ch = next_rec.get("chapter")
        rec["nav_next_label"] = (
            f"Chapter {ch} — {next_rec['title']}" if ch else next_rec["title"]
        )
    else:
        rec["nav_next_label"] = None

manifest = {"version": 1, "files": files}
OUT.write_text(yaml.dump(manifest, sort_keys=False, allow_unicode=True, width=120))
print(f"Wrote {OUT} ({len(files)} files, chapters 1-{max(f['chapter'] for f in files if f['chapter'])})")
