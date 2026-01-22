git_delete_branch() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "当前目录不是 Git 仓库。"
    return 1
  fi

  if [ "$#" -gt 1 ]; then
    echo "用法: git_delete_branch [branch]"
    return 1
  fi

  local target
  if [ "$#" -eq 0 ]; then
    target=$(git rev-parse --abbrev-ref HEAD)
  else
    target="$1"
  fi

  if [ "$target" = "master" ]; then
    echo "禁止删除 master 分支。"
    return 1
  fi

  local current
  current=$(git rev-parse --abbrev-ref HEAD)
  if [ "$target" = "$current" ]; then
    local fallback=""
    if git show-ref --verify --quiet refs/heads/master; then
      fallback="master"
    elif git show-ref --verify --quiet refs/heads/main; then
      fallback="main"
    fi

    if [ -z "$fallback" ]; then
      echo "无法切换到安全分支，取消删除。"
      return 1
    fi

    if [ "$fallback" = "$target" ]; then
      echo "禁止删除 master 分支。"
      return 1
    fi

    git checkout "$fallback" || return 1
  fi

  git branch -D "$target"
}
