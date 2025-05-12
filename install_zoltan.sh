#!/bin/bash

# Stop immediately if any command fails
set -e

# Edit these variables as needed
install_prefix="/Users/plahnsv/opm/install/zoltan"
parallel_build_tasks=4
trilinos_repo="https://github.com/trilinos/Trilinos.git"
trilinos_branch="trilinos-release-16-0-0"

# Step 1: Clone Trilinos if it doesn't exist
if [ ! -d "Trilinos" ]; then
  echo "Cloning Trilinos repository..."
  git clone $trilinos_repo
else
  echo "Trilinos directory already exists. Skipping clone."
fi

# Step 2: Checkout the correct branch
cd Trilinos

# Check if we're already on the right branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$current_branch" != "$trilinos_branch" ]; then
  echo "Checking out branch $trilinos_branch..."
  git fetch origin
  git checkout $trilinos_branch
else
  echo "Already on branch $trilinos_branch."
fi

# Step 3: Create and enter build directory
mkdir -p build
cd build

# Step 4: Configure with CMake
echo "Running CMake..."
cmake \
  -D CMAKE_INSTALL_PREFIX=$install_prefix \
  -D TPL_ENABLE_MPI:BOOL=ON \
  -D MPI_BASE_DIR:PATH=/usr/local \
  -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
  -D Trilinos_ENABLE_Zoltan:BOOL=ON \
  ../

# Step 5: Build
echo "Building Trilinos (this may take a while)..."
make -j $parallel_build_tasks

# Step 6: Install
echo "Installing to $install_prefix..."
make install

echo "✅ Trilinos with Zoltan installed successfully!"

