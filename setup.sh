#!/usr/bin/env bash
#
# setup.sh - Virtualmin Web Apps Suite Manager
# Automatically adds, updates, checks, or removes web app installers from Virtualmin
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="${SCRIPT_DIR}/apps"
LIB_DIR="${SCRIPT_DIR}/lib"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
VIRTUALMIN_CONFIG="/etc/webmin/virtual-server/config"
WEBMIN_CONFIG_DIR="/etc/webmin"

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}${BOLD}======================================================${NC}"
    echo -e "${BLUE}${BOLD}       Virtualmin Web Apps Suite Management CLI       ${NC}"
    echo -e "${BLUE}${BOLD}======================================================${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] This operation requires root privileges. Please run with sudo or as root.${NC}"
        exit 1
    fi
}

check_virtualmin() {
    if [[ ! -d "${WEBMIN_CONFIG_DIR}" ]]; then
        echo -e "${YELLOW}[WARNING] Webmin directory (${WEBMIN_CONFIG_DIR}) not found on this host.${NC}"
        echo -e "${YELLOW}          If you are on a development machine, actions will only prepare the local repository.${NC}"
        return 1
    fi
    if [[ ! -f "${VIRTUALMIN_CONFIG}" ]]; then
        echo -e "${YELLOW}[WARNING] Virtualmin config (${VIRTUALMIN_CONFIG}) not found.${NC}"
        echo -e "${YELLOW}          Is the Virtualmin virtual-server module installed?${NC}"
        return 1
    fi
    return 0
}

# Sync all apps from apps/<name>/<name>.pl to scripts/
sync_scripts_directory() {
    echo -e "${CYAN}[*] Synchronizing scripts directory (${SCRIPTS_DIR})...${NC}"
    mkdir -p "${SCRIPTS_DIR}"

    # Ensure lib symlink exists inside scripts/
    if [[ ! -e "${SCRIPTS_DIR}/lib" ]]; then
        ln -sfn "${LIB_DIR}" "${SCRIPTS_DIR}/lib"
    fi

    # Symlink all *.pl files from apps/*/*.pl into scripts/
    local count=0
    for app_dir in "${APPS_DIR}"/*; do
        if [[ -d "${app_dir}" ]]; then
            local app_name
            app_name=$(basename "${app_dir}")
            local pl_file="${app_dir}/${app_name}.pl"
            if [[ -f "${pl_file}" ]]; then
                ln -sfn "${pl_file}" "${SCRIPTS_DIR}/${app_name}.pl"
                count=$((count + 1))
            fi
        fi
    done

    echo -e "${GREEN}[+] Synchronized ${count} web application script(s).${NC}"
}

reload_webmin() {
    if command -v systemctl >/dev/null 2>&1; then
        echo -e "${CYAN}[*] Reloading Webmin service...${NC}"
        systemctl restart webmin 2>/dev/null || /etc/webmin/restart 2>/dev/null || true
    elif [[ -x /etc/webmin/restart ]]; then
        /etc/webmin/restart || true
    fi
}

do_install() {
    echo -e "${CYAN}[*] Installing Virtualmin Web Apps Suite...${NC}"
    sync_scripts_directory

    if check_virtualmin; then
        check_root
        # Read or set custom_scripts_dir in Virtualmin config
        if grep -q "^custom_scripts_dir=" "${VIRTUALMIN_CONFIG}"; then
            local current_dir
            current_dir=$(grep "^custom_scripts_dir=" "${VIRTUALMIN_CONFIG}" | cut -d'=' -f2)
            if [[ "${current_dir}" != "${SCRIPTS_DIR}" ]]; then
                echo -e "${YELLOW}[*] Updating existing custom_scripts_dir from ${current_dir} to ${SCRIPTS_DIR}${NC}"
                sed -i "s|^custom_scripts_dir=.*|custom_scripts_dir=${SCRIPTS_DIR}|" "${VIRTUALMIN_CONFIG}"
            else
                echo -e "${GREEN}[+] custom_scripts_dir is already set to ${SCRIPTS_DIR}${NC}"
            fi
        else
            echo -e "${CYAN}[*] Registering custom_scripts_dir=${SCRIPTS_DIR} in Virtualmin config...${NC}"
            echo "custom_scripts_dir=${SCRIPTS_DIR}" >> "${VIRTUALMIN_CONFIG}"
        fi

        reload_webmin
        echo -e "${GREEN}${BOLD}[SUCCESS] Virtualmin Web Apps Suite has been successfully installed and registered!${NC}"
        echo -e "${GREEN}Navigate to Virtualmin -> Manage Web Apps / Install Scripts to view and install these apps.${NC}"
    else
        echo -e "${GREEN}[+] Local scripts directory prepared at ${SCRIPTS_DIR}.${NC}"
    fi
}

do_update() {
    echo -e "${CYAN}[*] Updating Virtualmin Web Apps Suite...${NC}"
    
    # If this is a git clone, pull changes
    if [[ -d "${SCRIPT_DIR}/.git" ]] && command -v git >/dev/null 2>&1; then
        echo -e "${CYAN}[*] Pulling latest updates from Git repository...${NC}"
        git -C "${SCRIPT_DIR}" pull --rebase || true
    fi

    sync_scripts_directory

    if check_virtualmin; then
        check_root
        reload_webmin
    fi

    echo -e "${GREEN}${BOLD}[SUCCESS] Virtualmin Web Apps Suite is up to date!${NC}"
}

do_remove() {
    check_root
    echo -e "${YELLOW}[*] Removing Virtualmin Web Apps Suite registration...${NC}"

    if [[ -f "${VIRTUALMIN_CONFIG}" ]]; then
        sed -i "s|^custom_scripts_dir=${SCRIPTS_DIR}||g" "${VIRTUALMIN_CONFIG}"
        sed -i '/^$/d' "${VIRTUALMIN_CONFIG}"
        echo -e "${GREEN}[+] Removed custom_scripts_dir from Virtualmin configuration.${NC}"
        reload_webmin
    fi

    echo -e "${GREEN}[SUCCESS] Web apps unregistered from Virtualmin.${NC}"
}

do_status() {
    print_banner
    echo -e "${BOLD}System Status:${NC}"
    if [[ -d "${WEBMIN_CONFIG_DIR}" ]]; then
        echo -e "  Webmin Config:     ${GREEN}Found (${WEBMIN_CONFIG_DIR})${NC}"
    else
        echo -e "  Webmin Config:     ${YELLOW}Not Found (Non-server or custom location)${NC}"
    fi

    if [[ -f "${VIRTUALMIN_CONFIG}" ]]; then
        echo -e "  Virtualmin Config: ${GREEN}Found (${VIRTUALMIN_CONFIG})${NC}"
        local active_dir
        active_dir=$(grep "^custom_scripts_dir=" "${VIRTUALMIN_CONFIG}" 2>/dev/null | cut -d'=' -f2 || true)
        if [[ -n "${active_dir}" ]]; then
            echo -e "  Active Scripts Dir: ${GREEN}${active_dir}${NC}"
        else
            echo -e "  Active Scripts Dir: ${YELLOW}Not Set${NC}"
        fi
    else
        echo -e "  Virtualmin Config: ${YELLOW}Not Found${NC}"
    fi

    echo ""
    echo -e "${BOLD}Available Web Applications in Repo:${NC}"
    local count=0
    for app_dir in "${APPS_DIR}"/*; do
        if [[ -d "${app_dir}" ]]; then
            local name
            name=$(basename "${app_dir}")
            echo -e "  • ${BOLD}${name}${NC}"
            count=$((count + 1))
        fi
    done
    echo -e "Total Apps Available: ${GREEN}${count}${NC}"
}

do_list() {
    print_banner
    printf "${BOLD}%-20s %-15s %-12s %-40s${NC}\n" "APPLICATION" "CATEGORY" "VERSION" "DESCRIPTION"
    echo -e "------------------------------------------------------------------------------------------------"

    for app_dir in "${APPS_DIR}"/*; do
        if [[ -d "${app_dir}" ]]; then
            local name
            name=$(basename "${app_dir}")
            local pl_file="${app_dir}/${name}.pl"
            if [[ -f "${pl_file}" ]]; then
                # Extract metadata using perl one-liner
                local meta
                meta=$(perl -e '
                    require "'"${pl_file}"'";
                    my $d = main->can("script_'"${name}"'_desc") ? &{"script_'"${name}"'_desc"}() : "Unknown";
                    my $c = main->can("script_'"${name}"'_category") ? &{"script_'"${name}"'_category"}() : "General";
                    my @v = main->can("script_'"${name}"'_versions") ? &{"script_'"${name}"'_versions"}() : ("1.0");
                    print "$c\t$v[0]\t$d";
                ' 2>/dev/null || echo -e "Unknown\tUnknown\tNo metadata")

                local cat ver desc
                cat=$(echo "${meta}" | cut -f1)
                ver=$(echo "${meta}" | cut -f2)
                desc=$(echo "${meta}" | cut -f3)

                printf "%-20s %-15s %-12s %-40s\n" "${name}" "${cat}" "${ver}" "${desc}"
            fi
        fi
    done
    echo ""
}

do_test() {
    echo -e "${CYAN}[*] Running Perl syntax verification across all scripts and libraries...${NC}"
    local errors=0

    # Test libraries
    for lib in "${LIB_DIR}"/*.pl; do
        if [[ -f "${lib}" ]]; then
            if perl -cw -I"${LIB_DIR}" "${lib}" 2>&1 | grep -q "syntax OK"; then
                echo -e "  [PASS] ${lib}"
            else
                echo -e "  ${RED}[FAIL] ${lib}${NC}"
                perl -cw -I"${LIB_DIR}" "${lib}"
                errors=$((errors + 1))
            fi
        fi
    done

    # Test app scripts
    for app_dir in "${APPS_DIR}"/*; do
        if [[ -d "${app_dir}" ]]; then
            local name
            name=$(basename "${app_dir}")
            local pl="${app_dir}/${name}.pl"
            if [[ -f "${pl}" ]]; then
                if perl -cw -I"${LIB_DIR}" "${pl}" 2>&1 | grep -q "syntax OK"; then
                    echo -e "  [PASS] ${pl}"
                else
                    echo -e "  ${RED}[FAIL] ${pl}${NC}"
                    perl -cw -I"${LIB_DIR}" "${pl}"
                    errors=$((errors + 1))
                fi
            fi
        fi
    done

    if [[ ${errors} -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}[SUCCESS] All Perl scripts and libraries passed syntax validation!${NC}"
    else
        echo -e "${RED}${BOLD}[ERROR] ${errors} file(s) failed syntax validation.${NC}"
        exit 1
    fi
}

show_help() {
    print_banner
    echo -e "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install    Register and hook all web app scripts into Virtualmin"
    echo "  update     Sync scripts, pull latest git changes, and refresh Virtualmin"
    echo "  remove     Unregister web app scripts from Virtualmin configuration"
    echo "  status     Display integration status and configured script directory"
    echo "  list       Show table of all available web apps in this repository"
    echo "  test       Run perl syntax verification on all scripts and shared libs"
    echo "  help       Show this help message"
    echo ""
}

case "$1" in
    install)
        do_install
        ;;
    update)
        do_update
        ;;
    remove)
        do_remove
        ;;
    status)
        do_status
        ;;
    list)
        do_list
        ;;
    test)
        do_test
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}[ERROR] Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
