#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.codex"

echo "=== Codex CLI Configuration Installer ==="
echo "Target directory: ${TARGET_DIR}"

mkdir -p "${TARGET_DIR}/rules"

# 1. Install AGENTS.md
echo "[1/5] Installing global AGENTS.md..."
if [ -f "${TARGET_DIR}/AGENTS.md" ]; then
  cp "${TARGET_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md.bak"
fi
cp "${SCRIPT_DIR}/AGENTS.md" "${TARGET_DIR}/AGENTS.md"

# 2. Install Profiles
echo "[2/5] Installing model profiles..."
if [ -d "${SCRIPT_DIR}/profiles" ]; then
  cp "${SCRIPT_DIR}/profiles/"*.config.toml "${TARGET_DIR}/"
  echo "Installed profiles: $(ls "${SCRIPT_DIR}/profiles/"*.config.toml | xargs -n1 basename | tr '\n' ' ')"
fi

# 3. Install user skills
echo "[3/5] Installing user skills..."
if [ -d "${SCRIPT_DIR}/skills" ]; then
  mkdir -p "${TARGET_DIR}/skills"
  for skill_dir in "${SCRIPT_DIR}/skills"/*/; do
    [ -d "${skill_dir}" ] || continue
    skill_name="$(basename "${skill_dir}")"
    rm -rf "${TARGET_DIR}/skills/${skill_name}"
    cp -R "${skill_dir}" "${TARGET_DIR}/skills/${skill_name}"
    echo "      Installed skill: ${skill_name}"
  done
else
  echo "      (No user skills found; skipping)"
fi

# 4. Install default.rules
echo "[4/5] Installing execution rules..."
if [ -f "${TARGET_DIR}/rules/default.rules" ]; then
  cp "${TARGET_DIR}/rules/default.rules" "${TARGET_DIR}/rules/default.rules.bak"
fi
cp "${SCRIPT_DIR}/rules/default.rules" "${TARGET_DIR}/rules/default.rules"

# 5. Handle config.toml
echo "[5/5] Installing config.toml..."
if [ -f "${TARGET_DIR}/config.toml" ]; then
  echo "Found existing config.toml. Backing up to config.toml.bak..."
  cp "${TARGET_DIR}/config.toml" "${TARGET_DIR}/config.toml.bak"
  echo "Updating config.toml (preserving user settings backup)..."
  cp "${SCRIPT_DIR}/config.toml" "${TARGET_DIR}/config.toml"
else
  cp "${SCRIPT_DIR}/config.toml" "${TARGET_DIR}/config.toml"
fi

# 6. Verification
echo ""
echo "Verifying installation with --strict-config..."
if command -v codex >/dev/null 2>&1; then
  codex --strict-config exec --help >/dev/null
  echo "Verification passed! Codex configuration is active and strictly valid."
else
  echo "Codex binary not found in PATH; skipping verification."
fi

echo ""
echo "=== Installation Completed Successfully! ==="
echo "Tips:"
echo "  - Run 'codex -p deep' for high-reasoning complex architecture & debugging"
echo "  - Run 'codex -p review' for specialized code review"
echo "  - Run 'codex -p fast' to switch to lightweight fast model"
echo "  - Run 'codex -p grok' to switch to Grok profile"
echo "  - Run 'codex -p gemini' to switch to Gemini profile"
