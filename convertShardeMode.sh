#!/bin/bash -x

. convertShardeMode.conf

if [ -z "$GIT_ROOT" ]; then
    echo "Set a git repository first"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/shared-daemon" ]; then
    mkdir "$GIT_ROOT/shared-daemon"
    cp shared-daemon.config "$GIT_ROOT/shared-daemon/config"
fi

subgit daemon stop "$GIT_ROOT/shared-daemon"

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
        echo "    directory = $GIT_ROOT/shared-daemon" >> "$repo_source/subgit/config"
    fi

    ##Re Enable subgit configuration
    subgit install "$repo_source"
done <   <(find "$GIT_ROOT" -iname "*.git" -print0)

if [ -n "$GIT_UID" ] && [ -n "$GIT_GID" ]; then
    chown -r "$GIT_UID:$GIT_GIR" "$GIT_ROOT"
fi

subgit daemon start "$GIT_ROOT/shared-daemon"