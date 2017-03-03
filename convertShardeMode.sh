#!/bin/bash -x

. config.conf

if [ -z "$GIT_ROOT" ]; then
    echo "Set a git repository first"
    exit 1
fi

if [ ! -f "$PROJECT_ROOT/shared-daemon" ]; then
    mkdir "$GIT_ROOT/shared-daemon"
    cp shared-daemon.config "$GIT_ROOT/shared-daemon/config"
fi

for repo_source in $(find "$GIT_ROOT" -iname "*.git"); do
    echo "$repo_source"
    repo_name=$(basename "$repo_source" .git)

    ##Is a subgit project ?
    if [ ! -f "$repo_source/subgit/config" ]; then
        echo "Ignore project ; subgit translation not enabled"
        continue
    fi

    ##Is as shared mode ?
    if [ $(grep -r 'daemon "shared"' "$repo_source/subgit/config") ]; then
        echo "Shared daeamon yet enabled"
        continue
    fi

    ##Disable subgit configuration
    subgit uninstall "$repo_source"

    ##Set shared mode
    echo "[daemon \"shared\"]" >> "$repo_source/subgit/config"
    echo "    directory = $GIT_ROOT/shared-daemon" >> "$repo_source/subgit/config"

    ##Re Enable subgit configuration
    subgit install "$repo_source"
done