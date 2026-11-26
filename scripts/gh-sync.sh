#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<'EOF'
Usage: gh-sync.sh [OPTIONS] [ROOT_DIR]

Fetch, fast-forward default branches, and prune merged local branches across
all Git repositories under ROOT_DIR (default: ~/GitHub).

Options:
  -n, --dry-run     Show planned updates without modifying local branches
  --prune-gone      Also delete local branches whose remote upstream is [gone]
                    (useful after GitHub squash-merges; skips dirty checkouts)
  -h, --help        Show this help message
EOF
}

DRY_RUN=false
PRUNE_GONE=false
ROOT_DIR=""

while [ "$#" -gt 0 ]; do
	case "$1" in
	-n | --dry-run)
		DRY_RUN=true
		;;
	--prune-gone)
		PRUNE_GONE=true
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

if [ ! -d "$ROOT_DIR" ]; then
	echo "Directory not found: $ROOT_DIR" >&2
	exit 1
fi

total=0
updated=0
unchanged=0
skipped=0
pruned=0
gone_notices=0

while IFS= read -r git_dir; do
	repo_dir="$(dirname "$git_dir")"
	rel_path="${repo_dir#"$ROOT_DIR"/}"
	total=$((total + 1))

	if ! git -C "$repo_dir" remote get-url origin >/dev/null 2>&1; then
		printf '  skip   %-45s (no origin remote)\n' "$rel_path"
		skipped=$((skipped + 1))
		continue
	fi

	if ! git -C "$repo_dir" fetch --prune --quiet origin; then
		printf '  error  %-45s (fetch failed)\n' "$rel_path"
		skipped=$((skipped + 1))
		continue
	fi

	default_ref="$(git -C "$repo_dir" symbolic-ref --short -q refs/remotes/origin/HEAD || true)"
	if [ -n "$default_ref" ]; then
		default_branch="${default_ref#origin/}"
	elif git -C "$repo_dir" show-ref --verify --quiet refs/remotes/origin/main; then
		default_branch="main"
	elif git -C "$repo_dir" show-ref --verify --quiet refs/remotes/origin/master; then
		default_branch="master"
	else
		printf '  skip   %-45s (cannot detect default branch)\n' "$rel_path"
		skipped=$((skipped + 1))
		continue
	fi

	current_branch="$(git -C "$repo_dir" symbolic-ref --short -q HEAD || true)"
	dirty="$(git -C "$repo_dir" status --porcelain)"

	# If currently on a non-default branch whose upstream is gone and tree is clean,
	# switch back to the default branch when safe (fully merged or --prune-gone).
	if [ -n "$current_branch" ] && [ "$current_branch" != "$default_branch" ] && [ -z "$dirty" ]; then
		cur_track="$(git -C "$repo_dir" for-each-ref --format='%(upstream:track)' "refs/heads/$current_branch")"
		if [ "$cur_track" = "[gone]" ]; then
			is_merged=false
			if git -C "$repo_dir" merge-base --is-ancestor "$current_branch" "origin/$default_branch" 2>/dev/null; then
				is_merged=true
			fi
			if [ "$is_merged" = true ] || [ "$PRUNE_GONE" = true ]; then
				if [ "$DRY_RUN" = true ]; then
					printf '  plan   %-45s (checkout %s from gone branch %s)\n' "$rel_path" "$default_branch" "$current_branch"
				else
					git -C "$repo_dir" checkout --quiet "$default_branch"
					current_branch="$default_branch"
				fi
			fi
		fi
	fi

	# Fast-forward default branch
	if [ "$current_branch" = "$default_branch" ]; then
		if [ -n "$dirty" ]; then
			printf '  dirty  %-45s (on %s with local changes)\n' "$rel_path" "$default_branch"
			skipped=$((skipped + 1))
		else
			read -r ahead behind <<<"$(git -C "$repo_dir" rev-list --left-right --count "$default_branch...origin/$default_branch")"
			if [ "$behind" -gt 0 ] && [ "$ahead" -eq 0 ]; then
				if [ "$DRY_RUN" = true ]; then
					printf '  plan   %-45s (ff %s +%s commit(s))\n' "$rel_path" "$default_branch" "$behind"
				else
					git -C "$repo_dir" merge --ff-only --quiet "origin/$default_branch"
					printf '  sync   %-45s (ff %s +%s commit(s))\n' "$rel_path" "$default_branch" "$behind"
				fi
				updated=$((updated + 1))
			elif [ "$ahead" -gt 0 ]; then
				printf '  ahead  %-45s (%s ahead %s, behind %s)\n' "$rel_path" "$default_branch" "$ahead" "$behind"
				skipped=$((skipped + 1))
			else
				unchanged=$((unchanged + 1))
			fi
		fi
	else
		# On a feature branch or detached HEAD: safely fast-forward local default branch ref if possible
		if git -C "$repo_dir" show-ref --verify --quiet "refs/heads/$default_branch"; then
			read -r ahead behind <<<"$(git -C "$repo_dir" rev-list --left-right --count "$default_branch...origin/$default_branch")"
			if [ "$behind" -gt 0 ] && [ "$ahead" -eq 0 ]; then
				if [ "$DRY_RUN" = true ]; then
					printf '  plan   %-45s (ff %s +%s while on %s)\n' "$rel_path" "$default_branch" "$behind" "${current_branch:-HEAD}"
				else
					git -C "$repo_dir" fetch --quiet origin "$default_branch:$default_branch"
					printf '  sync   %-45s (ff %s +%s while on %s)\n' "$rel_path" "$default_branch" "$behind" "${current_branch:-HEAD}"
				fi
				updated=$((updated + 1))
			else
				printf '  branch %-45s (on %s%s)\n' "$rel_path" "${current_branch:-detached}" "${dirty:+, dirty}"
				skipped=$((skipped + 1))
			fi
		else
			printf '  branch %-45s (on %s%s)\n' "$rel_path" "${current_branch:-detached}" "${dirty:+, dirty}"
			skipped=$((skipped + 1))
		fi
	fi

	# Prune merged (or [gone] with --prune-gone) local branches
	while IFS=$'\t' read -r branch track; do
		[ -z "$branch" ] && continue
		[ "$branch" = "$default_branch" ] && continue
		[ "$branch" = "$current_branch" ] && continue

		if git -C "$repo_dir" merge-base --is-ancestor "$branch" "origin/$default_branch" 2>/dev/null; then
			if [ "$DRY_RUN" = true ]; then
				printf '  plan   %-45s (delete merged branch %s)\n' "$rel_path" "$branch"
			else
				git -C "$repo_dir" branch -d --quiet "$branch"
				printf '  prune  %-45s (deleted merged branch %s)\n' "$rel_path" "$branch"
			fi
			pruned=$((pruned + 1))
		elif [ "$track" = "[gone]" ]; then
			if [ "$PRUNE_GONE" = true ]; then
				if [ "$DRY_RUN" = true ]; then
					printf '  plan   %-45s (delete gone branch %s)\n' "$rel_path" "$branch"
				else
					git -C "$repo_dir" branch -D --quiet "$branch"
					printf '  prune  %-45s (deleted gone branch %s)\n' "$rel_path" "$branch"
				fi
				pruned=$((pruned + 1))
			else
				printf '  gone   %-45s (branch %s upstream gone; rerun with --prune-gone)\n' "$rel_path" "$branch"
				gone_notices=$((gone_notices + 1))
			fi
		fi
	done < <(git -C "$repo_dir" for-each-ref --format='%(refname:short)	%(upstream:track)' refs/heads)
done < <(find "$ROOT_DIR" -name .git -type d -prune | sort)

echo ""
echo "Summary: $total repos | $updated synced | $unchanged up-to-date | $skipped skipped | $pruned branches pruned | $gone_notices gone notices"
