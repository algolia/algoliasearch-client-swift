#!/usr/bin/env ksh

set -e # fail on first error

# Reflection.
SELF_ROOT=$(cd $(dirname "$0") && pwd)
PROJECT_ROOT=$(cd "$SELF_ROOT"/.. && pwd)

GIT_REPO_URL=$(cd "$PROJECT_ROOT" && git remote get-url origin)
BRANCH_NAME="gh-pages"
DST_DIR="$PROJECT_ROOT/build/doc"

# Prepare the destination directory
# ---------------------------------
# If the destination directory exists, make sure that it's a Git checkout of the `gh-pages` branch.
if [[ -d "$DST_DIR" ]]; then
    branch_name=$(cd "$DST_DIR" && git rev-parse --abbrev-ref HEAD)
    if [[ "$branch_name" != "$BRANCH_NAME" ]]; then
        echo "ERROR: Directory '$DST_DIR' is not a checkout of the '$BRANCH_NAME' branch!" 1>&2
        exit 1
    fi
    pwd=$(pwd)
    # Clean the Git checkout.
    echo "Git checkout found; cleaning"
    cd "$DST_DIR" && git clean -f
    cd "$pwd"
# Otherwise, create it.
else
    echo "No Git checkout found; cloning"
    mkdir -p $(dirname "$DST_DIR")
    git clone "$GIT_REPO_URL" -b "$BRANCH_NAME" --single-branch "$DST_DIR"
fi

# Make the documentation
# ----------------------
# Clean the destination directory.
# NOTE: We don't use Jazzy's `--clean` option because it deletes the destination directory; we want to preserve the
# Git checkout.
echo "Cleaning destination directory"
rm -rf "$DST_DIR"/*

# Generate the documentations with [Jazzy](https://github.com/realm/jazzy).
cd "$PROJECT_ROOT"

# Online flavor -> root directory.
echo "# Generating online flavor"
jazzy --config .jazzy.yaml

# Offline flavor -> `offline` subdirectory.
echo "# Generating offline flavor"
jazzy --config offline.jazzy.yaml
# NOTE: The offline flavor will be generated with a module name set to "AlgoliaSearchOffline", as in the Xcode project.
# But we wish to document it as "AlgoliaSearch" (same module name as the online client) because this is what is used
# in the Cocoapods spec. => Patch the generated files.
find "$DST_DIR/offline" -type f -exec sed -i '' -E 's/AlgoliaSearchOffline/AlgoliaSearch/g' {} \;

cp "$PROJECT_ROOT/LICENSE" "$DST_DIR/LICENSE.md"

echo 'Done. Git diff then add and commit.'
