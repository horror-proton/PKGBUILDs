#!/usr/bin/env bash
set -e

if test -z "$MAA_WINEPREFIX"; then
    export WINEPREFIX=${XDG_DATA_HOME:-$HOME/.local/share/maa-wpf-gui-wine/wineprefix}
else
    export WINEPREFIX="${MAA_WINEPREFIX?}"
fi

export WINEPREFIX=/tmp/maa/wineprefix

export MAA_WPF_FILES=/tmp/makepkg/maa-wpf-gui-wine/pkg/opt/maa-wpf-gui-wine
export MAA_WPF_ROOT=/tmp/maa/MAA
export WINE_INSTALL=/usr

runtime_url='https://download.visualstudio.microsoft.com/download/pr/c1d08a81-6e65-4065-b606-ed1127a954d3/14fe55b8a73ebba2b05432b162ab3aa8/windowsdesktop-runtime-8.0.4-win-x64.exe'
runtime_sha512sum='8a0b1ab3a774c33f46cd042783cf785c33f2d9e0bdeee4ff8bf96cfa90a2101a5711231840ef93eab101409e7f3f3770d86e1a55bd52709af08d1a6c908cc194'

bootstrap_wineprefix() {
    "$WINE_INSTALL"/bin/wineboot -u
}

install_runtime() {
    #local tmpdir="$(mktemp --directory)"
    local tmpdir=/tmp/installer
    mkdir -p "$tmpdir"
    pushd "$tmpdir"
    wget "$runtime_url"
    if ! wine ./windowsdesktop-runtime-*-win-x64.exe /install /quiet; then
        popd
        rm -rf "$tmpdir"
        exit 1
    fi
    popd
    rm -rf "$tmpdir"
}

start() {
    mkdir -p "$WINEPREFIX"
    if test ! -f "$WINEPREFIX"/.update-timestamp; then
        bootstrap_wineprefix
    fi
    if test ! -d "$WINEPREFIX"'/drive_c/Program Files/dotnet/shared/Microsoft.WindowsDesktop.App'; then
        install_runtime
    fi
}

start
