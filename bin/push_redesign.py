#!/usr/bin/env python3
"""Push puduu-app via GitHub Git Data API (urllib + raw surrogate).

Proven pattern: NEVER use git protocol or gh with the surrogate.
GOTCHA: GET ref = singular /git/ref/heads/<b>; PATCH ref = plural /git/refs/heads/<b>.
"""
import sys, json, base64, urllib.request, urllib.error
sys.path.insert(0, "/opt/hatch/skills/skill-creator/bin")
from dynamic_credentials import dynamic_credential_entry, ensure_allowed_url, read_json_response

OWNER, REPO = "verdynordsten", "puduu-app"
WORKDIR = "/home/hatch/workspace/puduu-app"
HOST = "api.github.com"
BASE = f"https://{HOST}"

FILES = [
    "lib/core/theme/puduu_theme.dart",
    "lib/widgets/puduu_widgets.dart",
    "lib/main.dart",
    "lib/features/today_page.dart",
    "lib/features/main_pages.dart",
    "lib/features/sub_pages.dart",
    "pubspec.yaml",
    "assets/fonts/Baloo2.ttf",
    "assets/fonts/Nunito.ttf",
    "design-system/puduu/MASTER.md",
    "mockups/index.html",
    "mockups/concepts.html",
    "bin/push_redesign.py",
]

DELETED = [
    "assets/fonts/Fraunces.ttf",
    "assets/fonts/Inter.ttf",
    "assets/fonts/Outfit.ttf",
    "assets/fonts/WorkSans.ttf",
]

COMMIT_MSG = (
    "Rebuild Candy Pop v12 (total redesign)\n\n"
    "- New fonts: Baloo 2 (display) + Nunito (UI); old fonts removed\n"
    "- puduu_theme.dart: candy palette (cream/coral/sun/grape/mint/sky),\n"
    "  PopStyle chunky material (3px ink borders, hard offset shadows)\n"
    "- puduu_widgets.dart: PopCard/PopButton/PopTile/PopBar (striped)/\n"
    "  Sticker/PopHero/PopBackground/TaskCard/NavRow, chunky task sheet\n"
    "- main.dart: chunky tab bar (white, ink border, colored active tabs)\n"
    "- All screens rewritten Candy Pop: Today/Focus/Reset/Progress/Yours/\n"
    "  Paywall/Routines/Calendar/Mood/Library/Onboarding (visual-only;\n"
    "  no logic, provider, RPC, navigation or copy changes)\n"
    "- design-system/puduu/MASTER.md v12, mockups (incl. 3 concepts)"
)

_surr = None
def surrogate():
    global _surr
    if _surr is None:
        _surr = str(dynamic_credential_entry("custom.github")["surrogate"]).strip()
    return _surr

def api(method, path, body=None):
    url = BASE + path
    ensure_allowed_url(url, [HOST])
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {surrogate()}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return read_json_response(resp)
    except urllib.error.HTTPError as e:
        detail = e.read().decode()[:500]
        raise RuntimeError(f"{method} {path} -> HTTP {e.code}: {detail}")

def main():
    repo = api("GET", f"/repos/{OWNER}/{REPO}")
    branch = repo["default_branch"]
    print(f"repo: {repo['full_name']} (branch {branch})")

    ref = api("GET", f"/repos/{OWNER}/{REPO}/git/ref/heads/{branch}")
    head_sha = ref["object"]["sha"]
    print("HEAD:", head_sha[:12])
    commit = api("GET", f"/repos/{OWNER}/{REPO}/git/commits/{head_sha}")
    base_tree = commit["tree"]["sha"]

    tree_entries = []
    for f in FILES:
        with open(f"{WORKDIR}/{f}", "rb") as fh:
            content = base64.b64encode(fh.read()).decode()
        blob = api("POST", f"/repos/{OWNER}/{REPO}/git/blobs",
                   {"content": content, "encoding": "base64"})
        tree_entries.append({"path": f, "mode": "100644",
                             "type": "blob", "sha": blob["sha"]})
        print(f"blob {f}: {blob['sha'][:8]}")
    for f in DELETED:
        tree_entries.append({"path": f, "mode": "100644",
                             "type": "blob", "sha": None})
        print(f"delete {f}")

    tree = api("POST", f"/repos/{OWNER}/{REPO}/git/trees",
               {"base_tree": base_tree, "tree": tree_entries})
    print("tree:", tree["sha"][:12])

    new_commit = api("POST", f"/repos/{OWNER}/{REPO}/git/commits",
                     {"message": COMMIT_MSG, "tree": tree["sha"],
                      "parents": [head_sha]})
    print("commit:", new_commit["sha"][:12])

    api("PATCH", f"/repos/{OWNER}/{REPO}/git/refs/heads/{branch}",
        {"sha": new_commit["sha"]})
    print(f"pushed {branch} -> {new_commit['sha'][:12]}")

if __name__ == "__main__":
    main()
