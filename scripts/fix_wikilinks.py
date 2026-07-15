#!/usr/bin/env python3
"""
Converts Obsidian embed syntax ![[filename.png]] (which GitHub does not render)
into standard markdown image syntax ![alt](relative/path.png) across the whole
vault, so screenshots display correctly on github.com as well as in Obsidian.

Resolution order for each ![[target]] found:
  1. If target already contains a path (e.g. Images/Forest/x.png) and that
     path exists on disk, use it directly.
  2. Otherwise look up the bare filename in an index built from everything
     under Images/. If exactly one file in the vault has that name, use it.
  3. If multiple files share that name (a handful of screenshots across
     different boxes are named the same thing, e.g. rootFlag.png), try to
     disambiguate using the referring note's own filename/folder name against
     the Images subfolder name, with a small ALIASES table for the cases
     where those two names don't match exactly (e.g. "Golden Eye.md" vs the
     "GoldenEye" Images subfolder).
  4. If it still can't be resolved (wrong extension, file never committed,
     etc.) the link is left untouched and reported so nothing gets silently
     mis-linked.

Non-image embeds (e.g. ![[somefile.php]]) are converted to a plain markdown
link instead of an image tag, since they aren't images.

Run from the repo root:
    python3 scripts/fix_wikilinks.py

Re-run any time after adding new boxes/screenshots that still use the
![[...]] embed syntax.
"""
import os, re, json, urllib.parse

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGE_EXTS = ('.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp')

# Add an entry here if a new box/topic's markdown filename doesn't match its
# Images/ subfolder name closely enough for the automatic normalized match
# to find it when disambiguating a collision.
ALIASES = {
    "cozy hosting": "CozyHosting",
    "golden eye": "GoldenEye",
    "onlyforyou": "Only4You",
    "nully cybersecurity": "NullyCTF",
    "blackhat": "Blackhat",
}


def norm(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())


def build_image_index(repo):
    index = {}
    for root, _dirs, files in os.walk(os.path.join(repo, "Images")):
        for fn in files:
            rel = os.path.relpath(os.path.join(root, fn), repo).replace("\\", "/")
            index.setdefault(fn, []).append(rel)
    return index


def process_file(path, image_index, report):
    with open(path, encoding='utf-8') as f:
        content = f.read()

    md_dir = os.path.dirname(path)
    fn = os.path.basename(path)
    md_stem_norm = norm(os.path.splitext(fn)[0])
    parent_norm = norm(os.path.basename(md_dir))
    state = {"changed": False}
    pat = re.compile(r'!\[\[([^\]]+)\]\]')

    def repl(m):
        target = m.group(1).strip()
        base = os.path.basename(target)
        ext = os.path.splitext(base)[1].lower()
        resolved_path = None

        if '/' in target:
            candidate = os.path.join(REPO, target)
            if os.path.isfile(candidate):
                resolved_path = target

        if resolved_path is None:
            candidates = image_index.get(base, [])
            if len(candidates) == 1:
                resolved_path = candidates[0]
            elif len(candidates) > 1:
                alias_target = ALIASES.get(md_stem_norm) or ALIASES.get(parent_norm)
                matched = None
                for c in candidates:
                    subfolder = c.split('/')[1] if c.startswith('Images/') else ''
                    if alias_target and norm(subfolder) == norm(alias_target):
                        matched = c
                        break
                    if norm(subfolder) == md_stem_norm or norm(subfolder) == parent_norm:
                        matched = c
                        break
                if matched:
                    resolved_path = matched
                    report["ambiguous_resolved_via_alias"].append((path, target, matched))
                else:
                    report["unresolved"].append((path, target, "ambiguous: " + str(candidates)))
                    return m.group(0)
            else:
                report["unresolved"].append((path, target, "no matching file found"))
                return m.group(0)

        state["changed"] = True
        report["resolved"] += 1
        rel = os.path.relpath(os.path.join(REPO, resolved_path), md_dir).replace("\\", "/")
        rel_encoded = urllib.parse.quote(rel)
        alt = os.path.splitext(base)[0]

        if ext in IMAGE_EXTS:
            return f"![{alt}]({rel_encoded})"
        return f"[{base}]({rel_encoded})"

    new_content = pat.sub(repl, content)
    if state["changed"]:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        report["files_changed"].append(path)


def main():
    image_index = build_image_index(REPO)
    report = {"resolved": 0, "ambiguous_resolved_via_alias": [], "unresolved": [], "files_changed": []}

    for root, dirs, files in os.walk(REPO):
        if any(seg in root for seg in ('.git', '.obsidian', 'Images', 'scripts')):
            continue
        for fn in files:
            if fn.endswith('.md'):
                process_file(os.path.join(root, fn), image_index, report)

    print("Files changed:", len(report["files_changed"]))
    print("Total links resolved:", report["resolved"])
    if report["ambiguous_resolved_via_alias"]:
        print("Resolved via alias/folder-name match:")
        for r in report["ambiguous_resolved_via_alias"]:
            print("  ", r)
    if report["unresolved"]:
        print("UNRESOLVED (left as-is, needs manual attention):")
        for r in report["unresolved"]:
            print("  ", r)


if __name__ == "__main__":
    main()
