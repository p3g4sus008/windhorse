#!/bin/bash

#-----------------------------#
# Windhorse Installation Script
#-----------------------------#

# Colors for output
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"

# Directories
BASE_DIR=$(pwd)
TOOLBOX_DIR="${BASE_DIR}/windhorse_toolbox"
mkdir -p "$TOOLBOX_DIR"

# Helper arrays
SUCCESS_INSTALL=()
SUCCESS_DOWNLOAD=()
FAILED_INSTALL=()

# Helper Functions
print_info() {
    echo -e "${GREEN}[INFO] $1${RESET}"
}

print_warning() {
    echo -e "${BLUE}[WARNING] $1${RESET}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

install_tool() {
    TOOL_NAME=$1
    INSTALL_COMMAND=$2

    if command -v "$TOOL_NAME" &> /dev/null; then
        print_info "$TOOL_NAME is already installed."
    else
        print_info "Installing $TOOL_NAME..."
        if eval "$INSTALL_COMMAND"; then
            print_info "$TOOL_NAME has been installed successfully."
            SUCCESS_INSTALL+=("$TOOL_NAME")
        else
            print_error "Failed to install $TOOL_NAME."
            FAILED_INSTALL+=("$TOOL_NAME")
        fi
    fi
}

download_script() {
    TOOL_NAME=$1
    REPO_URL=$2
    DEST_DIR="$TOOLBOX_DIR/$TOOL_NAME"

    if [ -d "$DEST_DIR" ]; then
        print_info "$TOOL_NAME is already downloaded."
    else
        print_info "Downloading $TOOL_NAME..."
        if git clone "$REPO_URL" "$DEST_DIR"; then
            print_info "$TOOL_NAME script has been downloaded."
            SUCCESS_DOWNLOAD+=("$TOOL_NAME")
        else
            print_error "Failed to download $TOOL_NAME."
            FAILED_INSTALL+=("$TOOL_NAME")
        fi
    fi
}

#-------------------------#
# System Preparation      #
#-------------------------#
print_info "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

print_info "Installing essential dependencies..."
sudo apt install -y git curl unzip wget python3-pip build-essential cargo rustup golang pipx || print_error "Failed to install essential dependencies."

#-------------------------#
# Tool Installations      #
#-------------------------#

# Example installations (extend this as needed):
install_tool "subfinder" "GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
install_tool "amass" "GO111MODULE=on go install -v github.com/owasp-amass/amass/v3/...@master"
install_tool "gau" "GO111MODULE=on go install github.com/lc/gau/v2/cmd/gau@latest"
install_tool "dnsvalidator" "pipx install git+https://github.com/vortexau/dnsvalidator.git"

# Example script downloads
download_script "SecLists" "https://github.com/danielmiessler/SecLists.git"
download_script "Sublist3r" "https://github.com/aboul3la/Sublist3r.git"
download_script "ReconFTW" "https://github.com/six2dez/reconftw.git"

#-------------------------#
# Summary Report          #
#-------------------------#
echo -e "\n${GREEN}${BOLD}Installation Summary:${RESET}"
if [ ${#SUCCESS_INSTALL[@]} -gt 0 ]; then
    echo -e "${GREEN}${BOLD}Successfully Installed Tools:${RESET}"
    for tool in "${SUCCESS_INSTALL[@]}"; do
        echo -e "${GREEN}  - $tool${RESET}"
    done
else
    echo -e "${RED}No tools were installed.${RESET}"
fi

if [ ${#SUCCESS_DOWNLOAD[@]} -gt 0 ]; then
    echo -e "${BLUE}${BOLD}Successfully Downloaded Scripts:${RESET}"
    for tool in "${SUCCESS_DOWNLOAD[@]}"; do
        echo -e "${BLUE}  - $tool${RESET}"
    done
else
    echo -e "${RED}No scripts were downloaded.${RESET}"
fi

if [ ${#FAILED_INSTALL[@]} -gt 0 ]; then
    echo -e "${RED}${BOLD}Tools that need manual installation:${RESET}"
    for tool in "${FAILED_INSTALL[@]}"; do
        echo -e "${RED}  - $tool${RESET}"
    done
else
    echo -e "${GREEN}All tools installed successfully!${RESET}"
fi
