#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage: gh-status.sh [OPTIONS] [ROOT_DIR]

Display a fleet status dashboard across GitHub repositories:
  1. All open pull requests for the authenticated GitHub user with CI status
  2. Local Git repositories under ROOT_DIR (default: ~/GitHub) that are dirty,
     on non-default branches, or ahead/behind origin

Options:
  --owner OWNER     GitHub owner to query for open PRs (default: authenticated gh user)
  --local-only      Skip GitHub API PR query and inspect local repos only
  -h, --help        Show this help message
EOF
}

OWNER=""
LOCAL_ONLY=false
ROOT_DIR=""

while [ "$#" -gt 0 ]; do
	case "$1" in
	--owner)
		shift
		OWNER="${1:-}"
		if [ -z "$OWNER" ]; then
			echo "Missing value for --owner" >&2
			exit 1
		fi
		;;
	--local-only)
		LOCAL_ONLY=true
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	*)
		if [ -n "$ROOT_DIR" ]; then
			echo "Unexpected argument: $1" >&2
			usage >&2
			exit 1
		fi
		ROOT_DIR="$1"
		;;
	esac
	shift
done

ROOT_DIR="${ROOT_DIR:-$HOME/GitHub}"

if [ "$LOCAL_ONLY" = false ] && command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
	if [ -z "$OWNER" ]; then
		OWNER="$(gh api user --jq '.login')"
	fi

	echo "=== Open Pull Requests ($OWNER) ==="
	OWNER="$OWNER" python3 - <<'PY'
import json
import os
import subprocess
import sys

owner = os.environ["OWNER"]
query = """
query($q: String!) {
  search(query: $q, type: ISSUE, first: 100) {
    nodes {
      ... on PullRequest {
        number
        title
        url
        isDraft
        repository { name }
        author { login }
        commits(last: 1) {
          nodes {
            commit {
              statusCheckRollup { state }
            }
          }
        }
      }
    }
  }
}
"""
res = subprocess.run(
    ["gh", "api", "graphql", "-f", f"query={query}", "-f", f"q=is:pr is:open archived:false user:{owner}"],
    capture_output=True,
    text=True,
)
if res.returncode != 0:
    print(f"  (failed to query GitHub GraphQL: {res.stderr.strip()})", file=sys.stderr)
    sys.exit(0)

nodes = json.loads(res.stdout).get("data", {}).get("search", {}).get("nodes", [])
if not nodes:
    print("  No open pull requests.")
    sys.exit(0)

nodes.sort(key=lambda n: (n["repository"]["name"], n["number"]))
counts = {"SUCCESS": 0, "PENDING": 0, "FAILURE": 0, "OTHER": 0}
for n in nodes:
    repo = n["repository"]["name"]
    num = n["number"]
    author = (n.get("author") or {}).get("login", "unknown")
    title = n["title"]
    if len(title) > 52:
        title = title[:49] + "..."
    commits = (n.get("commits") or {}).get("nodes") or []
    rollup = ((commits[0].get("commit") or {}).get("statusCheckRollup") or {}) if commits else {}
    state = rollup.get("state") or "NONE"
    if state in ("SUCCESS",):
        badge = "PASS"
        counts["SUCCESS"] += 1
    elif state in ("PENDING", "EXPECTED"):
        badge = "PEND"
        counts["PENDING"] += 1
    elif state in ("FAILURE", "ERROR"):
        badge = "FAIL"
        counts["FAILURE"] += 1
    else:
        badge = "NONE"
        counts["OTHER"] += 1
    draft = " [draft]" if n.get("isDraft") else ""
    print(f"  [{badge}] {repo:28s} #{num:<4d} ({author:15s}) {title}{draft}")

print(
    f"\n  Total: {len(nodes)} open PR(s) | "
    f"{counts['SUCCESS']} passing | {counts['PENDING']} pending | {counts['FAILURE']} failing"
)
PY
	echo ""
fi

if [ -d "$ROOT_DIR" ]; then
	echo "=== Local Repositories ($ROOT_DIR) ==="
	total=0
	attention=0
	while IFS= read -r git_dir; do
		repo_dir="$(dirname "$git_dir")"
		rel_path="${repo_dir#"$ROOT_DIR"/}"
		total=$((total + 1))

		default_ref="$(git -C "$repo_dir" symbolic-ref --short -q refs/remotes/origin/HEAD || true)"
		default_branch="${default_ref#origin/}"
		default_branch="${default_branch:-main}"
		branch="$(git -C "$repo_dir" symbolic-ref --short -q HEAD || echo "detached")"
		dirty="$(git -C "$repo_dir" status --porcelain)"

		notes=()
		if [ "$branch" != "$default_branch" ]; then
			notes+=("branch:$branch")
		fi
		if [ -n "$dirty" ]; then
			notes+=("dirty")
		fi
		if git -C "$repo_dir" rev-parse --abbrev-ref "@{u}" >/dev/null 2>&1; then
			read -r ahead behind <<<"$(git -C "$repo_dir" rev-list --left-right --count "HEAD...@{u}")"
			[ "$ahead" -gt 0 ] && notes+=("ahead:$ahead")
			[ "$behind" -gt 0 ] && notes+=("behind:$behind")
		fi

		if [ "${#notes[@]}" -gt 0 ]; then
			attention=$((attention + 1))
			joined="$(IFS=', '; echo "${notes[*]}")"
			printf '  %-45s %s\n' "$rel_path" "$joined"
		fi
	done < <(find "$ROOT_DIR" -name .git -type d -prune | sort)

	if [ "$attention" -eq 0 ]; then
		echo "  All $total local repositories are clean and on their default branch."
	else
		echo ""
		echo "  $attention/$total local repo(s) need attention."
	fi
fi
