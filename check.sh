#!/bin/bash

# Colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Helper Functions
print_info() {
    echo -e "${GREEN}[INFO] $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${RESET}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

# List of tools to verify
TOOLS=(
    "pipx"
    "golang"
    "eyewitness"
    "figlet"
    "subfinder"
    "assetfinder"
    "dnsgen"
    "massdns"
    "httprobe"
    "amass"
    "ffuf"
    "chromium"
    "dirsearch"
    "wpscan"
    "jq"
    "ruby"
    "cargo"
    "rustup"
    "dalfox"
    "gospider"
    "curl"
    "unzip"
    "wget"
    "reconftw"
    "sublist3r"
    "findomain"
    "gau"
    "aquatone"
    "waybackurls"
    "SecLists"
    "SubDomz"
    "Gxss"
    "MetaFinder"
    "xnLinkFinder"
    "waymore"
    "ParamSpider"
    "Interlace"
    "EmailFinder"
    "dedupe"
    "massdns"
    "ripgen"
    "ghauri"
    "dorks_hunter"
    "trufflehog"
    "tplmap"
    "XSStrike"
)

TOOLBOX_DIR="$HOME/toolbox"
SUCCESSFUL_TOOLS=()
TOOLBOX_TOOLS=()
FAILED_TOOLS=()

print_info "Checking installed tools..."

for tool in "${TOOLS[@]}"; do
    # Check if the tool is available as a command
    if command -v "$tool" &>/dev/null; then
        SUCCESSFUL_TOOLS+=("$tool")
    # Check if the tool exists in the toolbox directory
    elif [[ -d "$TOOLBOX_DIR/$tool" || -f "$TOOLBOX_DIR/$tool" ]]; then
        TOOLBOX_TOOLS+=("$tool")
    else
        FAILED_TOOLS+=("$tool")
    fi
done

# Display results
echo -e "\n${GREEN}Successfully Installed Tools:${RESET}"
for tool in "${SUCCESSFUL_TOOLS[@]}"; do
    echo -e "${GREEN}✔ $tool${RESET}"
done

echo -e "\n${YELLOW}Tools Found in Toolbox:${RESET}"
for tool in "${TOOLBOX_TOOLS[@]}"; do
    echo -e "${YELLOW}⚠ $tool (Present in toolbox)${RESET}"
done

echo -e "\n${RED}Failed Tools:${RESET}"
for tool in "${FAILED_TOOLS[@]}"; do
    echo -e "${RED}✘ $tool (Install manually in $TOOLBOX_DIR)${RESET}"
done

# Final summary
echo -e "\n${GREEN}Summary:${RESET}"
echo -e "${GREEN}✔ Successfully installed: ${#SUCCESSFUL_TOOLS[@]} tools${RESET}"
echo -e "${YELLOW}⚠ Found in toolbox: ${#TOOLBOX_TOOLS[@]} tools${RESET}"
echo -e "${RED}✘ Failed: ${#FAILED_TOOLS[@]} tools${RESET}"