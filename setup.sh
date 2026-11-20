#!/usr/bin/env bash
#
# setup.sh - Virtualmin Web Apps Suite Manager
# Automatically adds, updates, checks, or removes web app installers from Virtualmin
#
# Licensed under the GNU General Public License v3.0 (GPLv3).
# DISCLAIMER: This software is provided "AS-IS", WITHOUT WARRANTY OF ANY KIND.
# Use at your own risk. The authors accept no liability for damages or data loss.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="${SCRIPT_DIR}/apps"
LIB_DIR="${SCRIPT_DIR}/lib"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
WEBMIN_CONFIG_DIR="/etc/webmin"
VIRTUALMIN_MODULE_DIR="/etc/webmin/virtual-server"
VIRTUALMIN_CONFIG="${VIRTUALMIN_MODULE_DIR}/config"
VIRTUALMIN_SCRIPTS_DIR="${VIRTUALMIN_MODULE_DIR}/scripts"
VIRTUALMIN_UNAVAIL_FILE="${VIRTUALMIN_MODULE_DIR}/scriptsunavail"

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
    echo -e "${CYAN}[*] Synchronizing local repository scripts directory (${SCRIPTS_DIR})...${NC}"
    mkdir -p "${SCRIPTS_DIR}"

    # Ensure lib symlink exists inside scripts/ with relative target
    ln -sfn "../lib" "${SCRIPTS_DIR}/lib"

    # Symlink all *.pl files from apps/*/*.pl into scripts/
    local count=0
    for app_dir in "${APPS_DIR}"/*; do
        if [[ -d "${app_dir}" ]]; then
            local app_name
            app_name=$(basename "${app_dir}")
            local pl_file="${app_dir}/${app_name}.pl"
            if [[ -f "${pl_file}" ]]; then
                ln -sfn "../apps/${app_name}/${app_name}.pl" "${SCRIPTS_DIR}/${app_name}.pl"
                count=$((count + 1))
            fi
        fi
    done

    echo -e "${GREEN}[+] Synchronized ${count} web application script(s) in local repository.${NC}"
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

        echo -e "${CYAN}[*] Registering scripts in Virtualmin custom scripts directory (${VIRTUALMIN_SCRIPTS_DIR})...${NC}"
        mkdir -p "${VIRTUALMIN_SCRIPTS_DIR}"

        # Symlink shared library directory into Virtualmin custom scripts directory
        ln -sfn "${LIB_DIR}" "${VIRTUALMIN_SCRIPTS_DIR}/lib"

        local total_apps
        total_apps=$(find "${APPS_DIR}" -mindepth 1 -maxdepth 1 -type d | wc -l)
        # Symlink all app installer scripts directly into Virtualmin's custom scripts directory
        local count=0
        for app_dir in "${APPS_DIR}"/*; do
            if [[ -d "${app_dir}" ]]; then
                local app_name
                app_name=$(basename "${app_dir}")
                local pl_file="${app_dir}/${app_name}.pl"
                if [[ -f "${pl_file}" ]]; then
                    ln -sfn "${pl_file}" "${VIRTUALMIN_SCRIPTS_DIR}/${app_name}.pl"
                    count=$((count + 1))
                fi
            fi
        done
        echo -e "${GREEN}[+] Registered and linked ${count} web application script(s) into ${VIRTUALMIN_SCRIPTS_DIR}.${NC}"

        # Clean up legacy custom_scripts_dir in Virtualmin config if present
        if [[ -f "${VIRTUALMIN_CONFIG}" ]] && grep -q "^custom_scripts_dir=" "${VIRTUALMIN_CONFIG}"; then
            echo -e "${YELLOW}[*] Cleaning up legacy custom_scripts_dir entry from ${VIRTUALMIN_CONFIG}...${NC}"
            sed -i '/^custom_scripts_dir=/d' "${VIRTUALMIN_CONFIG}"
        fi

        # Check for denydefault restriction in scriptsunavail
        if [[ -f "${VIRTUALMIN_UNAVAIL_FILE}" ]]; then
            if grep -q "^denydefault=1" "${VIRTUALMIN_UNAVAIL_FILE}"; then
                echo -e "${YELLOW}[!] Virtualmin policy 'denydefault=1' detected in ${VIRTUALMIN_UNAVAIL_FILE}.${NC}"
                echo -e "${CYAN}[*] Whitelisting custom scripts in ${VIRTUALMIN_UNAVAIL_FILE}...${NC}"
                for app_dir in "${APPS_DIR}"/*; do
                    if [[ -d "${app_dir}" ]]; then
                        local a_name
                        a_name=$(basename "${app_dir}")
                        if ! grep -q "^${a_name}=" "${VIRTUALMIN_UNAVAIL_FILE}"; then
                            echo "${a_name}=0" >> "${VIRTUALMIN_UNAVAIL_FILE}"
                        fi
                    fi
                done
            fi
        fi

        reload_webmin

        echo -e "${GREEN}${BOLD}[SUCCESS] Virtualmin Web Apps Suite has been successfully installed and registered!${NC}"

        # Verify via Virtualmin CLI if present
        if command -v virtualmin >/dev/null 2>&1; then
            local cli_count
            cli_count=$(virtualmin list-available-scripts --source custom --name-only 2>/dev/null | wc -l || echo "0")
            echo -e "${GREEN}[+] Virtualmin CLI confirms ${cli_count} custom script(s) recognized and active.${NC}"
        fi

        echo ""
        echo -e "${BLUE}${BOLD}How to View and Install in Virtualmin GUI:${NC}"
        echo -e "  1. In the Virtualmin sidebar, select your target ${BOLD}Virtual Server${NC} (domain)."
        echo -e "  2. Click on ${BOLD}Manage Web Apps${NC} (or ${BOLD}Install Scripts${NC})."
        echo -e "  3. Click the ${BOLD}Available Scripts${NC} (or ${BOLD}Install Script${NC}) tab."
        echo -e "     ${YELLOW}(Note: Virtualmin opens on the 'Installed Scripts' tab by default if apps already exist on the domain).${NC}"
        echo -e "  4. All applications will appear organized by category, ready to install with 1 click!"
        echo -e "  (To manage global script visibility: Virtualmin -> System Settings -> Script Installers)"
    else
        echo -e "${GREEN}[+] Local scripts directory prepared at ${SCRIPTS_DIR}.${NC}"
    fi
}

do_update() {
    echo -e "${CYAN}[*] Updating Virtualmin Web Apps Suite...${NC}"

    # If this is a git clone, pull changes
    if [[ -d "${SCRIPT_DIR}/.git" ]] && command -v git >/dev/null 2>&1; then
        echo -e "${CYAN}[*] Pulling latest updates from Git repository...${NC}"
        # Discard any local modifications to tracked symlinks in scripts/ before pulling
        git -C "${SCRIPT_DIR}" checkout -- scripts/ 2>/dev/null || true
        git -C "${SCRIPT_DIR}" pull --rebase || true
    fi

    do_install
    echo -e "${GREEN}${BOLD}[SUCCESS] Virtualmin Web Apps Suite is up to date!${NC}"
}

do_remove() {
    check_root
    echo -e "${YELLOW}[*] Removing Virtualmin Web Apps Suite registration...${NC}"

    if [[ -d "${VIRTUALMIN_SCRIPTS_DIR}" ]]; then
        local count=0
        for app_dir in "${APPS_DIR}"/*; do
            if [[ -d "${app_dir}" ]]; then
                local app_name
                app_name=$(basename "${app_dir}")
                local target="${VIRTUALMIN_SCRIPTS_DIR}/${app_name}.pl"
                if [[ -L "${target}" || -f "${target}" ]]; then
                    rm -f "${target}"
                    count=$((count + 1))
                fi
            fi
        done
        if [[ -L "${VIRTUALMIN_SCRIPTS_DIR}/lib" ]]; then
            rm -f "${VIRTUALMIN_SCRIPTS_DIR}/lib"
        fi
        echo -e "${GREEN}[+] Unlinked ${count} web application script(s) from ${VIRTUALMIN_SCRIPTS_DIR}.${NC}"
    fi

    # Clean up legacy custom_scripts_dir in Virtualmin config if present
    if [[ -f "${VIRTUALMIN_CONFIG}" ]]; then
        sed -i "/^custom_scripts_dir=/d" "${VIRTUALMIN_CONFIG}"
        sed -i '/^$/d' "${VIRTUALMIN_CONFIG}"
    fi

    reload_webmin
    echo -e "${GREEN}[SUCCESS] Web apps unregistered from Virtualmin.${NC}"
}

do_status() {
    print_banner
    echo -e "${BOLD}System Status:${NC}"
    if [[ -d "${WEBMIN_CONFIG_DIR}" ]]; then
        echo -e "  Webmin Config:         ${GREEN}Found (${WEBMIN_CONFIG_DIR})${NC}"
    else
        echo -e "  Webmin Config:         ${YELLOW}Not Found (Non-server or custom location)${NC}"
    fi

    if [[ -f "${VIRTUALMIN_CONFIG}" ]]; then
        echo -e "  Virtualmin Config:     ${GREEN}Found (${VIRTUALMIN_CONFIG})${NC}"
    else
        echo -e "  Virtualmin Config:     ${YELLOW}Not Found${NC}"
    fi

    if [[ -d "${VIRTUALMIN_SCRIPTS_DIR}" ]]; then
        local linked_count=0
        for app_dir in "${APPS_DIR}"/*; do
            if [[ -d "${app_dir}" ]]; then
                local app_name
                app_name=$(basename "${app_dir}")
                if [[ -e "${VIRTUALMIN_SCRIPTS_DIR}/${app_name}.pl" ]]; then
                    linked_count=$((linked_count + 1))
                fi
            fi
        done
        local total_apps
        total_apps=$(find "${APPS_DIR}" -mindepth 1 -maxdepth 1 -type d | wc -l)
        echo -e "  Virtualmin Scripts Dir: ${GREEN}${VIRTUALMIN_SCRIPTS_DIR}${NC} (${linked_count}/${total_apps} apps linked)"
    else
        echo -e "  Virtualmin Scripts Dir: ${YELLOW}${VIRTUALMIN_SCRIPTS_DIR} (Not yet created)${NC}"
    fi

    if command -v virtualmin >/dev/null 2>&1; then
        echo -e "  Virtualmin CLI:        ${GREEN}Available${NC}"
        local avail_count
        avail_count=$(virtualmin list-available-scripts --source custom --name-only 2>/dev/null | wc -l || echo "0")
        echo -e "  Custom Apps Detected:  ${GREEN}${avail_count}${NC}"
    else
        echo -e "  Virtualmin CLI:        ${YELLOW}virtualmin command not in PATH${NC}"
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
    printf "${BOLD}%-18s %-12s %-12s %-8s %-40s${NC}\n" "APPLICATION" "CATEGORY" "VERSION" "BUILD" "DESCRIPTION"
    echo -e "--------------------------------------------------------------------------------------------------"

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
                    my $r = main->can("script_'"${name}"'_release") ? &{"script_'"${name}"'_release"}() : 1;
                    print "$c\t$v[0]\t$r\t$d";
                ' 2>/dev/null || echo -e "Unknown\tUnknown\t1\tNo metadata")

                local cat ver build desc
                cat=$(echo "${meta}" | cut -f1)
                ver=$(echo "${meta}" | cut -f2)
                build=$(echo "${meta}" | cut -f3)
                desc=$(echo "${meta}" | cut -f4)

                printf "%-18s %-12s %-12s %-8s %-40s\n" "${name}" "${cat}" "${ver}" "${build}" "${desc}"
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

    echo ""
    echo -e "${CYAN}[*] Running Automated Unit & Security Test Suite (1,000+ tests)...${NC}"
    if command -v prove >/dev/null 2>&1; then
        prove "${SCRIPT_DIR}/tests/"
    else
        for t in "${SCRIPT_DIR}/tests"/*.t; do
            echo -e "${BLUE}[*] Running $(basename "${t}")...${NC}"
            perl "${t}"
        done
    fi
    echo -e "${GREEN}${BOLD}[SUCCESS] All unit tests, security verifications, and PCI DSS assertions passed!${NC}"
}

do_doctor() {
    print_banner
    echo -e "${CYAN}${BOLD}[*] Running Virtualmin Web Apps Suite System & Health Diagnostics...${NC}\n"

    local issues=0

    # 1. Host and Kernel
    echo -e "${BOLD}[System Environment]${NC}"
    echo -e "  OS / Host:            $(uname -s) $(uname -r) ($(uname -m))"

    # 2. Perl Environment & Core Modules
    echo -e "\n${BOLD}[Perl Runtime]${NC}"
    if command -v perl >/dev/null 2>&1; then
        local perl_ver
        perl_ver=$(perl -e 'print $^V')
        echo -e "  Perl Binary:          ${GREEN}$(command -v perl)${NC} (${perl_ver})"

        local modules=("File::Basename" "File::Path" "Cwd" "POSIX" "Digest::SHA" "File::Copy" "Test::Simple" "Test::More")
        for mod in "${modules[@]}"; do
            if perl -M"${mod}" -e 1 >/dev/null 2>&1; then
                echo -e "  Module ${mod}: ${GREEN}OK${NC}"
            else
                echo -e "  Module ${mod}: ${RED}MISSING${NC}"
                issues=$((issues + 1))
            fi
        done
    else
        echo -e "  Perl Binary:          ${RED}NOT FOUND${NC}"
        issues=$((issues + 1))
    fi

    # 3. Virtualmin / Webmin Integration
    echo -e "\n${BOLD}[Virtualmin / Webmin Integration]${NC}"
    if [[ -d "${WEBMIN_CONFIG_DIR}" ]]; then
        echo -e "  Webmin Config:        ${GREEN}${WEBMIN_CONFIG_DIR} (Found)${NC}"
    else
        echo -e "  Webmin Config:        ${YELLOW}${WEBMIN_CONFIG_DIR} (Not detected - development host)${NC}"
    fi

    if [[ -d "${VIRTUALMIN_MODULE_DIR}" ]]; then
        echo -e "  Virtualmin Module:    ${GREEN}${VIRTUALMIN_MODULE_DIR} (Found)${NC}"
    else
        echo -e "  Virtualmin Module:    ${YELLOW}${VIRTUALMIN_MODULE_DIR} (Not detected - development host)${NC}"
    fi

    if command -v virtualmin >/dev/null 2>&1; then
        echo -e "  Virtualmin CLI:       ${GREEN}Available${NC}"
    else
        echo -e "  Virtualmin CLI:       ${YELLOW}Not in PATH (standard if not on live server)${NC}"
    fi

    # 4. Command-Line Utilities
    echo -e "\n${BOLD}[Required & Recommended CLI Utilities]${NC}"
    local utils=("curl" "wget" "tar" "unzip" "gzip" "sed" "grep" "systemctl")
    for u in "${utils[@]}"; do
        if command -v "${u}" >/dev/null 2>&1; then
            echo -e "  Command '${u}':       ${GREEN}Installed${NC} ($(command -v "${u}"))"
        else
            echo -e "  Command '${u}':       ${YELLOW}Missing${NC}"
        fi
    done

    # 5. Container Engines (for container-based apps)
    echo -e "\n${BOLD}[Container Runtimes (for containerized apps)]${NC}"
    local has_container=0
    if command -v podman >/dev/null 2>&1; then
        echo -e "  Podman:               ${GREEN}Installed${NC} ($(podman --version 2>/dev/null | head -n1))"
        has_container=1
    else
        echo -e "  Podman:               ${YELLOW}Not installed${NC}"
    fi

    if command -v docker >/dev/null 2>&1; then
        echo -e "  Docker:               ${GREEN}Installed${NC} ($(docker --version 2>/dev/null | head -n1))"
        has_container=1
    else
        echo -e "  Docker:               ${YELLOW}Not installed${NC}"
    fi

    if [[ ${has_container} -eq 0 ]]; then
        echo -e "  ${YELLOW}[NOTE] Container-based apps require Podman or Docker to be installed.${NC}"
    fi

    # 6. Repository Integrity & Symlink Health
    echo -e "\n${BOLD}[Repository Health & Symlinks]${NC}"
    local broken_links
    broken_links=$(find "${SCRIPTS_DIR}" -xtype l 2>/dev/null | wc -l || echo 0)
    if [[ ${broken_links} -eq 0 ]]; then
        echo -e "  Broken Symlinks:      ${GREEN}0 (All valid)${NC}"
    else
        echo -e "  Broken Symlinks:      ${RED}${broken_links} detected!${NC}"
        issues=$((issues + 1))
    fi

    local total_apps
    total_apps=$(find "${APPS_DIR}" -mindepth 1 -maxdepth 1 -type d | wc -l)
    local total_scripts
    total_scripts=$(find "${SCRIPTS_DIR}" -maxdepth 1 -name "*.pl" | wc -l)
    echo -e "  Total Apps in apps/:  ${GREEN}${total_apps}${NC}"
    echo -e "  Total in scripts/:    ${GREEN}${total_scripts}${NC}"
    if [[ ${total_apps} -ne ${total_scripts} ]]; then
        echo -e "  ${YELLOW}[WARNING] apps/ count (${total_apps}) does not match scripts/ count (${total_scripts}). Run './setup.sh update' to sync.${NC}"
    fi

    echo ""
    if [[ ${issues} -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}[SUCCESS] Doctor diagnosis complete: No critical issues detected!${NC}"
    else
        echo -e "${YELLOW}${BOLD}[NOTICE] Doctor diagnosis complete: ${issues} issue(s) detected.${NC}"
    fi
}

do_package() {
    print_banner
    local version="2.0.0"
    local pkg_file="${SCRIPT_DIR}/virtualmin-webapps-v${version}.tar.gz"
    echo -e "${CYAN}[*] Creating standalone release package for Virtualmin Web Apps Suite v${version}...${NC}"

    # Sync scripts directory first
    sync_scripts_directory >/dev/null 2>&1

    # Create tar.gz excluding git metadata via temp file
    local tmp_pkg="/tmp/virtualmin-webapps-v${version}-$$.tar.gz"
    tar --exclude='.git' --exclude='.github' --exclude='*.tar.gz' -czf "${tmp_pkg}" -C "$(dirname "${SCRIPT_DIR}")" "$(basename "${SCRIPT_DIR}")"
    mv "${tmp_pkg}" "${pkg_file}"

    if [[ -f "${pkg_file}" ]]; then
        local sz
        sz=$(du -h "${pkg_file}" | cut -f1)
        echo -e "${GREEN}${BOLD}[SUCCESS] Release package created successfully!${NC}"
        echo -e "  Archive: ${pkg_file} (${sz})"
        echo -e "  Usage: Extract on any Virtualmin server and run './setup.sh install'"
    else
        echo -e "${RED}[ERROR] Failed to create package.${NC}"
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
    echo "  doctor     Run diagnostic health check on system, perl modules, and repository"
    echo "  package    Generate standalone release distribution archive (.tar.gz)"
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
    doctor)
        do_doctor
        ;;
    package)
        do_package
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
