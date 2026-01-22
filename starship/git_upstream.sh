git rev-parse --abbrev-ref HEAD 2>/dev/null || exit 0
branch=$(git rev-parse --abbrev-ref HEAD)

upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) || {
  echo "$branch"
  exit 0
}

remote=${upstream%%/*}
up_branch=${upstream#*/}

if [ "$branch" = "$up_branch" ]; then
  echo "$branch @ $remote"
else
  echo "$branch → $upstream"
fi