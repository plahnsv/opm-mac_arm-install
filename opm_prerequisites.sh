#!/bin/bash
# === prerequisites.sh ===
# Install core prerequisites for building OPM with Python bindings and optional documentation tools on macOS ARM

set -e  # Exit immediately on error

echo "🔧 Installing OPM prerequisites with Homebrew..."

# Function to check and install a formula if missing
install_if_missing() {
  if ! brew list --formula | grep -q "^$1\$"; then
    echo "📦 Installing $1..."
    brew install "$1"
  else
    echo "✅ $1 already installed."
  fi
}

# Function to check and install a cask (GUI app) if missing
install_cask_if_missing() {
  if ! brew list --cask | grep -q "^$1\$"; then
    echo "📦 Installing cask: $1..."
    brew install --cask "$1"
  else
    echo "✅ Cask $1 already installed."
  fi
}

# === Core build tools ===
install_if_missing cmake
install_if_missing ninja
install_if_missing pkg-config
install_if_missing doxygen
install_if_missing swig  # Needed for Python bindings

# === Scientific libraries ===
install_if_missing boost
install_if_missing suite-sparse
install_if_missing open-mpi
install_if_missing zlib

# === Optional GUI/doc tools ===
install_cask_if_missing mactex
install_cask_if_missing inkscape

# === Python bindings support (via pyenv) ===
echo
if ! command -v pyenv &>/dev/null; then
  echo "⚠️  pyenv not found. Consider installing it to safely manage Python versions:"
  echo "    brew install pyenv"
else
  echo "✅ pyenv is installed."
fi

echo
echo "✅ All required and optional packages for OPM are now handled."

