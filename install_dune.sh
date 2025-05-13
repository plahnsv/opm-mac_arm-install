#!/bin/bash
# === install_dune.sh ===
# Clone, build, and install DUNE modules with optional Python bindings

set -e  # Exit on any error

# === USER CONFIGURATION ===
OPM_ROOT="$HOME/opm"
SRC_DIR="$OPM_ROOT/src"
BUILD_DIR="$OPM_ROOT/build/dune"
INSTALL_PREFIX="$OPM_ROOT/install/dune"
LOG_FILE="$OPM_ROOT/logs/dune_build_$(date +%Y-%m-%d_%H-%M-%S).log"
CMAKE_OPTIONS_FILE="$BUILD_DIR/dune_options.cmake"
MODULES=(dune-common dune-geometry dune-grid dune-istl)
ENABLE_PYTHON=true  # Set to false to disable Python bindings

mkdir -p "$BUILD_DIR"
echo "DUNE Build started at $(date)" > "$LOG_FILE"

# === PREPARE CMAKE OPTIONS ===
cat << EOF > "$CMAKE_OPTIONS_FILE"
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type")
set(CMAKE_PREFIX_PATH "$INSTALL_PREFIX" CACHE STRING "Installation prefix")
EOF

if [ "$ENABLE_PYTHON" = true ]; then
  echo "set(DUNE_ENABLE_PYTHONBINDINGS ON CACHE BOOL \"Enable Python bindings\")" >> "$CMAKE_OPTIONS_FILE"
else
  echo "set(DUNE_ENABLE_PYTHONBINDINGS OFF CACHE BOOL \"Disable Python bindings\")" >> "$CMAKE_OPTIONS_FILE"
fi

# === CLONE, BUILD, INSTALL EACH MODULE ===
cd "$SRC_DIR"

for REPO in "${MODULES[@]}"; do
  echo "===================================================" | tee -a "$LOG_FILE"
  echo "=== Cloning and building module: $REPO" | tee -a "$LOG_FILE"
  echo "===================================================" | tee -a "$LOG_FILE"

  if [ ! -d "$REPO" ]; then
    git clone https://gitlab.dune-project.org/core/$REPO.git | tee -a "$LOG_FILE"
    if [ $? -ne 0 ]; then
      echo "Error cloning $REPO — exiting." | tee -a "$LOG_FILE"
      exit 1
    fi
  else
    echo "$REPO already exists — skipping clone." | tee -a "$LOG_FILE"
  fi

  mkdir -p "$BUILD_DIR/$REPO"
  cd "$BUILD_DIR/$REPO"

  cmake -C "$CMAKE_OPTIONS_FILE" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        "$SRC_DIR/$REPO" | tee -a "$LOG_FILE"

  make -j "$(sysctl -n hw.logicalcpu)" | tee -a "$LOG_FILE"
  make install | tee -a "$LOG_FILE"
  cd "$SRC_DIR"
done

# === PATCH remoteindices.hh IF NEEDED ===
REMOTE_FILE="$INSTALL_PREFIX/include/dune/common/parallel/remoteindices.hh"
if grep -q 'attribute_==ri.attribute;' "$REMOTE_FILE"; then
  echo "Patching remoteindices.hh for Clang compatibility..." | tee -a "$LOG_FILE"
  sed -i '' 's/attribute_==ri.attribute;/attribute_==ri.attribute_/g' "$REMOTE_FILE"
fi

echo "✅ DUNE Build complete at $(date)" | tee -a "$LOG_FILE"

