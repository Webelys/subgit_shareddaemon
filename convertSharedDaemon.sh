#!/bin/bash -x

. convertSharedDaemon.conf

if [ -z "$GIT_DIRECTORY" ]; then
    echo "Set a git repository first"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT_SUBGIT/shared-daemon" ]; then
    mkdir "$PROJECT_ROOT_SUBGIT/shared-daemon"
    cp shared-daemon.config "$PROJECT_ROOT_SUBGIT/shared-daemon/config"
fi

subgit daemon stop "$PROJECT_ROOT_SUBGIT/shared-daemon"

while IFS= read -r -d '' repo_source
do
    echo "$repo_source"
    repo_name=$(basename "$repo_source" .git)

    ##Is a subgit project ?
    if [ ! -f "$repo_source/subgit/config" ]; then
        echo "Ignore project ; subgit translation not enabled"
        continue
    fi

    ##Disable subgit configuration
    ##Redo subgit installation (prevent partial state, configured but not installed)
    subgit uninstall "$repo_source"

    ##Is not shared mode ? then configure subgit 
    if ! grep -qr 'daemon "shared"' "$repo_source/subgit/config"; then
        ##Set shared mode
        echo "[daemon \"shared\"]" >> "$repo_source/subgit/config"
        echo "    directory = $PROJECT_ROOT_SUBGIT/shared-daemon" >> "$repo_source/subgit/config"
    fi

    ##Re Enable subgit configuration
    subgit install "$repo_source"
done <   <(find "$GIT_DIRECTORY" -iname "*.git" -print0)

if [ -n "$GIT_UID" ] && [ -n "$GIT_GID" ]; then
    chown -r "$GIT_UID:$GIT_GIR" "$GIT_DIRECTORY"
fi

subgit daemon start "$PROJECT_ROOT_SUBGIT/shared-daemon"