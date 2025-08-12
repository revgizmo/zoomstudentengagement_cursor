#!/usr/bin/env python3
import json
import os
import re
import sys
from pathlib import Path

import requests

MANIFEST_PATH = Path(__file__).parent / "issues_manifest.json"
TRACKING_TITLE = "Documentation overhaul (v0.2)"
MILESTONE_TITLE = "v0.2 Docs polish"
DEFAULT_LABELS = ["docs"]

API = "https://api.github.com"


def die(msg: str, code: int = 1):
    print(msg, file=sys.stderr)
    sys.exit(code)


def get_repo_from_git() -> str:
    import subprocess

    try:
        url = (
            subprocess.check_output(["git", "config", "--get", "remote.origin.url"], text=True)
            .strip()
        )
    except subprocess.CalledProcessError:
        die("Unable to determine git remote.origin.url")

    # Accept https or git@ forms
    m = re.match(r"https?://github.com/([^/]+/[^/]+)(?:.git)?$", url)
    if m:
        return m.group(1)
    m = re.match(r"git@github.com:([^/]+/[^/]+)(?:.git)?$", url)
    if m:
        return m.group(1)
    die(f"Unrecognized GitHub remote URL: {url}")


def gh_headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "issue-creator-script",
    }


def ensure_labels(owner_repo: str, token: str, labels: set):
    existing = requests.get(f"{API}/repos/{owner_repo}/labels", headers=gh_headers(token))
    existing.raise_for_status()
    names = {l["name"] for l in existing.json()}
    for name in labels - names:
        color = "1f883d" if name == "docs" else "0e8a16"
        requests.post(
            f"{API}/repos/{owner_repo}/labels",
            headers=gh_headers(token),
            json={"name": name, "color": color},
        ).raise_for_status()


def ensure_milestone(owner_repo: str, token: str, title: str) -> int:
    r = requests.get(f"{API}/repos/{owner_repo}/milestones?state=all", headers=gh_headers(token))
    r.raise_for_status()
    for m in r.json():
        if m["title"] == title:
            return m["number"]
    r = requests.post(
        f"{API}/repos/{owner_repo}/milestones",
        headers=gh_headers(token),
        json={"title": title},
    )
    r.raise_for_status()
    return r.json()["number"]


def create_issue(owner_repo: str, token: str, title: str, body: str, labels: list, milestone: int) -> int:
    r = requests.post(
        f"{API}/repos/{owner_repo}/issues",
        headers=gh_headers(token),
        json={
            "title": title,
            "body": body,
            "labels": labels or DEFAULT_LABELS,
            "milestone": milestone,
        },
    )
    r.raise_for_status()
    num = r.json()["number"]
    url = r.json()["html_url"]
    print(f"Created issue #{num}: {url}")
    return num


def main():
    token = os.getenv("GH_TOKEN")
    if not token:
        die("GH_TOKEN env var is required. Export a GitHub token with repo scope.")

    owner_repo = get_repo_from_git()

    if not MANIFEST_PATH.exists():
        die(f"Manifest not found: {MANIFEST_PATH}")

    issues = json.loads(MANIFEST_PATH.read_text())

    # Collect all labels
    label_set = set(DEFAULT_LABELS)
    for it in issues:
        for l in it.get("labels", []):
            label_set.add(l)

    ensure_labels(owner_repo, token, label_set)
    milestone_num = ensure_milestone(owner_repo, token, MILESTONE_TITLE)

    created = []
    for it in issues:
        num = create_issue(
            owner_repo,
            token,
            it["title"],
            it.get("body", ""),
            it.get("labels", DEFAULT_LABELS),
            milestone_num,
        )
        created.append({"number": num, "title": it["title"]})

    # Tracking issue body linking to all
    body_lines = [
        "Goal\n- Improve first-run success, clarify privacy, align links/site.\n",
        "Scope\n- README, vignettes, pkgdown, function refs, CI badges, FAQ.\n",
        "Checklist",
    ]
    for c in created:
        body_lines.append(f"- [ ] #{c['number']} {c['title']}")
    body = "\n".join(body_lines)

    tracking_num = create_issue(
        owner_repo,
        token,
        TRACKING_TITLE,
        body,
        ["docs", "tracking"],
        milestone_num,
    )

    print("\nAll set.")
    print(f"Tracking issue: #{tracking_num}")


if __name__ == "__main__":
    main()