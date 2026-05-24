#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"
BACKUP_ROOT="${HOME}/.config_backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

SOURCE_PATHS=(
  "${REPO_DIR}/nvim"
  "${REPO_DIR}/borders"
  "${REPO_DIR}/yabai"
  "${REPO_DIR}/skhd"
  "${REPO_DIR}/yabai/yabairc"
  "${REPO_DIR}/skhd/skhdrc"
  "${REPO_DIR}/sketchybar"
  "${REPO_DIR}/starship"
  "${REPO_DIR}/zellij"
  "${REPO_DIR}/zsh/.zshrc"
)

DEST_PATHS=(
  "${CONFIG_DIR}/nvim"
  "${CONFIG_DIR}/borders"
  "${CONFIG_DIR}/yabai"
  "${CONFIG_DIR}/skhd"
  "${HOME}/.yabairc"
  "${HOME}/.skhdrc"
  "${CONFIG_DIR}/sketchybar"
  "${CONFIG_DIR}/starship"
  "${CONFIG_DIR}/zellij"
  "${HOME}/.zshrc"
)

mkdir -p "${CONFIG_DIR}"

backup_created=0

for i in "${!SOURCE_PATHS[@]}"; do
  src="${SOURCE_PATHS[$i]}"
  dst="${DEST_PATHS[$i]}"
  backup_name="$(basename "${dst}")"

  if [[ ! -e "${src}" ]]; then
    echo "[WARN] 源路径不存在，跳过: ${src}"
    continue
  fi

  if [[ -L "${dst}" ]]; then
    rm "${dst}"
    echo "[INFO] 已移除软链: ${dst}"
  elif [[ -e "${dst}" ]]; then
    if [[ "${backup_created}" -eq 0 ]]; then
      mkdir -p "${BACKUP_DIR}"
      backup_created=1
    fi
    mv "${dst}" "${BACKUP_DIR}/${backup_name}"
    echo "[INFO] 已备份: ${dst} -> ${BACKUP_DIR}/${backup_name}"
  fi

  ln -s "${src}" "${dst}"
  echo "[OK] 已创建软链: ${dst} -> ${src}"
done

if [[ "${backup_created}" -eq 1 ]]; then
  echo "[DONE] 备份目录: ${BACKUP_DIR}"
else
  echo "[DONE] 没有需要备份的现有配置。"
fi
