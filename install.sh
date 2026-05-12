#!/usr/bin/env bash
set -euo pipefail

green='\033[0;32m'
bred='\033[1;31m'
cyan='\033[0;36m'
grey='\033[2;37m'
reset='\033[0m'

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SILENT_DIR="/usr/share/sddm/themes/silent"
CONFIG_NAME="makima"
CONFIG_FILE="${CONFIG_NAME}.conf"
BG_FILE="${CONFIG_NAME}.png"

warn()  { echo -e "${bred}[!]${reset} $1"; }
info()  { echo -e "${grey}[*]${reset} $1"; }
ok()    { echo -e "${green}[+]${reset} $1"; }
cmd()   { echo -e "${cyan}[>]${reset} $1"; }

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTIONS]

Install the Makima SDDM theme for SilentSDDM.

Options:
  --skip-silent-install    Skip SilentSDDM installation check
  --skip-test              Don't prompt to test the theme
  --skip-sddm-restart      Don't prompt to restart SDDM
  --help                   Show this help
EOF
    exit 0
}

SKIP_SILENT_INSTALL=false
SKIP_TEST=false
SKIP_SDDM_RESTART=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-silent-install) SKIP_SILENT_INSTALL=true; shift ;;
        --skip-test)           SKIP_TEST=true;           shift ;;
        --skip-sddm-restart)   SKIP_SDDM_RESTART=true;   shift ;;
        --help)                usage ;;
        *) warn "Unknown option: $1"; usage ;;
    esac
done

check_prereqs() {
    info "Checking prerequisites..."

    if [[ ! -f /usr/bin/sddm ]]; then
        warn "SDDM is not installed. Install it first:"
        cmd "sudo dnf install sddm"
        exit 1
    fi

    if ! systemctl is-active sddm &>/dev/null; then
        warn "SDDM is installed but not the active display manager."
        warn "Make sure SDDM is configured as your DM before restarting."
    fi

    if [[ -d "$SILENT_DIR" && -f "$SILENT_DIR/metadata.desktop" ]]; then
        ok "SilentSDDM found at $SILENT_DIR"
        return 0
    else
        return 1
    fi
}

install_silentsddm() {
    local tmpdir
    tmpdir="$(mktemp -d)"

    info "Downloading SilentSDDM..."
    git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM.git "$tmpdir" 2>/dev/null || {
        warn "Failed to clone SilentSDDM. Check your internet connection."
        rm -rf "$tmpdir"
        exit 1
    }

    info "Running SilentSDDM install script (this may ask for sudo)..."
    cd "$tmpdir"
    bash install.sh
    cd "$REPO_DIR"

    rm -rf "$tmpdir"
}

deploy_theme() {
    info "Deploying Makima theme files..."

    sudo mkdir -p "$SILENT_DIR/configs" "$SILENT_DIR/backgrounds"

    if [[ ! -f "$REPO_DIR/$CONFIG_FILE" ]]; then
        warn "Missing $CONFIG_FILE in repo directory."
        exit 1
    fi
    sudo cp "$REPO_DIR/$CONFIG_FILE" "$SILENT_DIR/configs/$CONFIG_FILE"
    ok "Copied $CONFIG_FILE → $SILENT_DIR/configs/"

    if [[ -f "$REPO_DIR/$BG_FILE" ]]; then
        sudo cp "$REPO_DIR/$BG_FILE" "$SILENT_DIR/backgrounds/$BG_FILE"
        ok "Copied $BG_FILE → $SILENT_DIR/backgrounds/"
    else
        warn "Missing $BG_FILE — background won't be copied."
    fi
}

configure_metadata() {
    local mdfile="$SILENT_DIR/metadata.desktop"

    if [[ ! -f "$mdfile" ]]; then
        warn "metadata.desktop not found at $mdfile"
        warn "SilentSDDM may not have been installed correctly."
        exit 1
    fi

    if grep -q "^ConfigFile=configs/${CONFIG_NAME}.conf" "$mdfile"; then
        ok "metadata.desktop already points to $CONFIG_NAME.conf"
        return
    fi

    info "Backing up metadata.desktop → metadata.desktop.bak"
    sudo cp "$mdfile" "$mdfile.bak"

    if grep -q "^ConfigFile=" "$mdfile"; then
        sudo sed -i "s|^ConfigFile=.*|ConfigFile=configs/${CONFIG_NAME}.conf|" "$mdfile"
    else
        echo "ConfigFile=configs/${CONFIG_NAME}.conf" | sudo tee -a "$mdfile" >/dev/null
    fi

    ok "metadata.desktop updated to use $CONFIG_NAME.conf"
}

test_theme() {
    if [[ ! -x "$SILENT_DIR/test.sh" ]]; then
        warn "SilentSDDM test.sh not found. You can test later by running:"
        cmd "cd $SILENT_DIR && ./test.sh"
        return
    fi

    echo ""
    read -rp "Run theme test now? (launches a preview window) [Y/n] " yn
    case "$yn" in
        [Nn]*) info "Skipping test. Run later: cd $SILENT_DIR && ./test.sh" ;;
        *)
            info "Launching test..."
            cd "$SILENT_DIR"
            ./test.sh
            cd "$REPO_DIR"
            ;;
    esac
}

restart_sddm() {
    warn "This will end your current session!"
    read -rp "Restart SDDM now? [y/N] " yn
    case "$yn" in
        [Yy]*) sudo systemctl restart sddm ;;
        *)     info "Skipping restart. Restart manually: sudo systemctl restart sddm" ;;
    esac
}

main() {
    echo ""
    echo -e "${green}╔══════════════════════════════════════╗${reset}"
    echo -e "${green}║     Makima-SDDM Theme Installer      ║${reset}"
    echo -e "${green}╚══════════════════════════════════════╝${reset}"
    echo ""

    if ! check_prereqs; then
        echo ""
        warn "SilentSDDM is not installed."
        if [[ "$SKIP_SILENT_INSTALL" == true ]]; then
            info "Skipping SilentSDDM installation (--skip-silent-install)."
            info "Install it manually from: https://github.com/uiriansan/SilentSDDM"
            exit 1
        fi
        read -rp "Install SilentSDDM now? [Y/n] " yn
        case "$yn" in
            [Nn]*) info "Aborted."; exit 1 ;;
            *)     install_silentsddm ;;
        esac
    fi

    echo ""
    deploy_theme

    echo ""
    configure_metadata

    echo ""
    ok "Makima theme installed successfully!"

    if [[ "$SKIP_TEST" == false ]]; then
        test_theme
    else
        info "Skipping test. Run later: cd $SILENT_DIR && ./test.sh"
    fi

    echo ""
    if [[ "$SKIP_SDDM_RESTART" == false ]]; then
        restart_sddm
    else
        info "Skipping restart. Restart manually when ready:"
        cmd "sudo systemctl restart sddm"
    fi
}

main "$@"
