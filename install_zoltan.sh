#!/bin/bash

# === install_zoltan.sh ===
# Clone, build, and install Trilinos with Zoltan

set -e  # Exit on error

# === USER CONFIGURATION ===
OPM_ROOT="$HOME/opm"
SRC_DIR="$OPM_ROOT/src"
BUILD_DIR="$OPM_ROOT/build/zoltan"
INSTALL_PREFIX="$OPM_ROOT/install/zoltan"
LOG_FILE="$OPM_ROOT/logs/zoltan_build_$(date +%Y-%m-%d_%H-%M-%S).log"

TRILINOS_REPO="https://github.com/trilinos/Trilinos.git"
TRILINOS_BRANCH="trilinos-release-16-0-0"
PARALLEL_JOBS=4

echo "==== Zoltan Install Script ====" | tee "$LOG_FILE"
echo "Cloning Trilinos source to $SRC_DIR" | tee -a "$LOG_FILE"

# === Clone Trilinos if needed ===
cd "$SRC_DIR"
if [ ! -d "Trilinos" ]; then
  git clone "$TRILINOS_REPO" Trilinos | tee -a "$LOG_FILE"
else
  echo "Trilinos already exists, skipping clone." | tee -a "$LOG_FILE"
fi

cd Trilinos
git fetch origin | tee -a "$LOG_FILE"
git checkout "$TRILINOS_BRANCH" | tee -a "$LOG_FILE"

# === Configure build ===
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Running CMake..." | tee -a "$LOG_FILE"
cmake \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DTPL_ENABLE_MPI=ON \
  -DMPI_BASE_DIR=/usr/local \
  -DTrilinos_ENABLE_ALL_PACKAGES=OFF \
  -DTrilinos_ENABLE_Zoltan=ON \
  "$SRC_DIR/Trilinos" | tee -a "$LOG_FILE"

# === Build and install ===
echo "Building Trilinos..." | tee -a "$LOG_FILE"
make -j "$PARALLEL_JOBS" | tee -a "$LOG_FILE"

echo "Installing to $INSTALL_PREFIX..." | tee -a "$LOG_FILE"
make install | tee -a "$LOG_FILE"

echo "✅ Trilinos with Zoltan installed successfully!" | tee -a "$LOG_FILE"

