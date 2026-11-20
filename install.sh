#!/usr/bin/env bash
#
# install.sh - 1-Click Bootstrap Installer for Virtualmin Web Apps Suite
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/turajbjt/virtualminWebApps/main/install.sh | sudo bash
#
# Licensed under the GNU General Public License v3.0 (GPLv3).
#

set -e

# Formatting colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TARGET_DIR="/opt/virtualminWebApps"
REPO_URL="https://github.com/turajbjt/virtualminWebApps.git"

print_banner() {
    echo -e "${BLUE}${BOLD}======================================================${NC}"
    echo -e "${BLUE}${BOLD}   Virtualmin Web Apps Suite - 1-Click Bootstrap      ${NC}"
    echo -e "${BLUE}${BOLD}======================================================${NC}"
}

print_banner

# Require root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] This installer must be run as root (or with sudo).${NC}"
    exit 1
fi

echo -e "${CYAN}[*] Checking prerequisites...${NC}"

# Check for perl
if ! command -v perl >/dev/null 2>&1; then
    echo -e "${YELLOW}[!] Perl is not installed. Installing perl...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq && apt-get install -y -qq perl git curl tar
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y perl git curl tar
    elif command -v yum >/dev/null 2>&1; then
        yum install -y perl git curl tar
    fi
fi

# Clone or update repository
if [[ -d "${TARGET_DIR}/.git" ]]; then
    echo -e "${CYAN}[*] Updating existing installation in ${TARGET_DIR}...${NC}"
    git -C "${TARGET_DIR}" pull --rebase || true
elif [[ -d "${TARGET_DIR}" ]]; then
    echo -e "${YELLOW}[*] Directory ${TARGET_DIR} exists without git. Reinstalling...${NC}"
    git clone --depth 1 "${REPO_URL}" "${TARGET_DIR}"
else
    echo -e "${CYAN}[*] Cloning Virtualmin Web Apps Suite into ${TARGET_DIR}...${NC}"
    mkdir -p "$(dirname "${TARGET_DIR}")"
    git clone "${REPO_URL}" "${TARGET_DIR}"
fi

cd "${TARGET_DIR}"

# Run diagnostic check
echo -e "${CYAN}[*] Running system diagnostics...${NC}"
./setup.sh doctor || true

# Run suite installer
echo -e "${CYAN}[*] Registering 100+ application installers into Virtualmin...${NC}"
./setup.sh install

echo -e "\n${GREEN}${BOLD}======================================================${NC}"
echo -e "${GREEN}${BOLD} [SUCCESS] Virtualmin Web Apps Suite Installed!       ${NC}"
echo -e "${GREEN}${BOLD}======================================================${NC}"
echo -e "  Installed Directory: ${BOLD}${TARGET_DIR}${NC}"
echo -e "  To manage apps in Virtualmin:"
echo -e "    1. Log into Virtualmin (https://your-server-ip:10000)"
echo -e "    2. Select your Virtual Server domain"
echo -e "    3. Navigate to: ${BOLD}Manage Web Apps${NC} (or ${BOLD}Install Scripts${NC})"
echo -e "    4. Browse 100+ applications organized by 24 categories!\n"
