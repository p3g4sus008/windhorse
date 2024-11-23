#!/bin/bash

#-----------------------------#
#      Automated Installer    #
#-----------------------------#

# Colors for output
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'
NC='\033[0m'

# Helper Functions
print_info() {
    echo -e "${GREEN}[INFO] $1${RESET}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

#--------------------#
# System Preparation #
#--------------------#
print_info "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y || print_error "Failed to update/upgrade system."

echo -e "${GREEN}---------------------Start Installing System Tools---------------------\n\n"
declare -A TOOLS_TO_INSTALL=(
    [pipx]=pipx
    [golang]=golang
    [eyewitness]=eyewitness
    [figlet]=figlet
    [subfinder]=subfinder
    [assetfinder]=assetfinder
    [dnsgen]=dnsgen
    [massdns]=massdns
    [httprobe]=httprobe
    [amass]=amass
    [ffuf]=ffuf
    [chromium]=chromium
    [dirsearch]=dirsearch
    [wpscan]=wpscan
    [libcurl4-openssl-dev]=libcurl4-openssl-dev
    [libssl-dev]=libssl-dev
    [jq]=jq
    [ruby-full]=ruby-full
    [libxml2-dev]=libxml2-dev
    [libxslt1-dev]=libxslt1-dev
    [build-essential]=build-essential
    [libgmp-dev]=libgmp-dev
    [zlib1g-dev]=zlib1g-dev
    [python3-pip]=python3-pip
    [git]=git
    [rename]=rename
    [xargs]=xargs
    [dalfox]=dalfox
    [reling]=reling
    [gospider]=gospider
    [curl]=curl
    [unzip]=unzip
    [wget]=wget
    [cargo]=cargo
    [rustup]=rustup
    [python-dev]=python-dev
)

for tool in "${!TOOLS_TO_INSTALL[@]}"; do
    if command_exists "$tool"; then
        print_info "$tool is already installed."
    else
        sudo apt-get install -y "${TOOLS_TO_INSTALL[$tool]}" || print_error "Failed to install $tool."
    fi
done

#-------------------------#
# Install Security Tools  #
#-------------------------#
TOOLBOX_DIR="$HOME/toolbox"
mkdir -p "$TOOLBOX_DIR"
cd "$TOOLBOX_DIR" || exit


echo -e "${GREEN}Start Installing Subdomain Enumeration Tools\n\n\n"
print_info "Installing SubDomz..."
git clone https://github.com/0xPugal/SubDomz.git
cd SubDomz || exit
chmod +x install.sh SubDomz.sh check.sh
sed -i -e 's/\r$//' install.sh SubDomz.sh
./install.sh && ./check.sh || print_error "Failed to install SubDomz."
sudo mv SubDomz.sh /usr/bin/subdomz
cd ..

print_info "Installing ReconFTW..."
git clone https://github.com/six2dez/reconftw.git
cd reconftw || exit
chmod +x install.sh
./install.sh || print_error "Failed to install ReconFTW."
sudo pip3 install -r requirements.txt --break-system-packages
cd ..

if command_exists "sublist3"; then
    print_info "sublist3r" is already installed."
else
    print_info "Installing Sublist3r..."
    git clone https://github.com/aboul3la/Sublist3r.git
    cd Sublist3r || exit
    sudo pip3 install -r requirements.txt --break-system-packages || print_error "Failed to install Sublist3r dependencies."
    sudo pip3 install requests
    sudo pip3 install dnspython
    sudo pip3 install argparse
    sudo ln -s "$(pwd)/sublist3r.py" /usr/bin/sublist3r
    cd ..
fi

if command_exists "findomain"; then
    print_info "findomain" is already installed."
else
  print_info "Installing Findomain..."
  git clone https://github.com/findomain/findomain.git
  cd findomain || exit
  cargo build --release
  sudo cp target/release/findomain /usr/bin/
  cd ..
fi


if command_exists "gxss"; then
    print_info "gxss" is already installed."
else
    git clone https://github.com/KathanP19/Gxss.git
    cd Gxss
    go install
    cd ..
fi

if command_exists "massdns"; then
    print_info "massdns" is already installed."
else
    git clone https://github.com/blechschmidt/massdns.git && cd massdns && make && sudo make install && cd ..fi

if command_exists "gf"; then
    print_info "gf" is already installed."
else
    git clone https://github.com/tomnomnom/gf.git
    cd gf
    go install
    cd ..
fi

echo -e "${GREEN}Cloning Github Repositories\n\n\n"
declare -A REPOS_TO_CLONE=(
    [XSStrike]="https://github.com/s0md3v/XSStrike.git"
    [tplmap]="https://github.com/epinna/tplmap.git"
    [massdns]="https://github.com/blechschmidt/massdns.git"
    [nmapAutomator]="https://github.com/21y4d/nmapAutomator.git"
    [Arjun]="https://github.com/s0md3v/Arjun.git"
    [gf]="https://github.com/tomnomnom/gf.git"
    [ParamSpider]="https://github.com/0xKayala/ParamSpider.git"
    [xnLinkFinder]="https://github.com/xnl-h4ck3r/xnLinkFinder.git"
    [waymore]="https://github.com/xnl-h4ck3r/waymore.git"
    [dnsvalidator]="https://github.com/vortexau/dnsvalidator.git"
    [MetaFinder]="https://github.com/Josue87/MetaFinder.git"
    [Interlace]="https://github.com/codingo/Interlace.git"
    [EmailFinder]="https://github.com/Josue87/EmailFinder.git"
    [dedupe]="https://github.com/dedupeio/dedupe.git"
    [SecLists]="https://github.com/danielmiessler/SecLists.git"
    [Gf-Patterns]="https://github.com/1ndianl33t/Gf-Patterns.git"
    [SubDomz]="https://github.com/0xPugal/SubDomz.git"
    [reconftw]="https://github.com/six2dez/reconftw.git"
    [Sublist3r]="https://github.com/aboul3la/Sublist3r.git"
    [findomain]="https://github.com/findomain/findomain.git"
    [trufflehog]="https://github.com/trufflesecurity/trufflehog.git"
)

for repo in "${!REPOS_TO_CLONE[@]}"; do
    if dir_exists "$TOOLBOX_DIR/$repo"; then
        print_info "Repository $repo already exists in $TOOLBOX_DIR."
    else
        git clone "${REPOS_TO_CLONE[$repo]}" || print_error "Failed to clone $repo."
    fi
done

#-------------------------#
# Install Additional Tools#
#-------------------------#

# Installing gau
if ! command_exists gau; then
    print_info "Installing gau (Get All URLs)..."
    wget -q "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz"
    tar -xf gau_2.2.4_linux_amd64.tar.gz
    sudo mv gau /usr/bin/
else
    print_info "gau is already installed."
fi

# Installing Aquatone
if ! command_exists aquatone; then
    print_info "Installing Aquatone for snapshots..."
    wget -q "https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip"
    unzip -q aquatone_linux_amd64_1.7.0.zip
    sudo mv aquatone /usr/bin/
else
    print_info "Aquatone is already installed."
fi

# Installing Waybackurls
if ! command_exists waybackurls; then
    print_info "Installing Waybackurls..."
    wget -q "https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz"
    tar -xf waybackurls-linux-amd64-0.1.0.tgz
    sudo mv waybackurls /usr/bin/
else
    print_info "Waybackurls is already installed."
fi

#------------------------#
# Install Go Tools       #
#------------------------#
GO_TOOLS=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/owasp-amass/amass/v3/...@master"
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    "github.com/hakluke/haktrails@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/gwen001/github-subdomains@latest"
    "github.com/gwen001/gitlab-subdomains@latest"
    "github.com/glebarez/cero@latest"
    "github.com/incogbyte/shosubgo@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/tomnomnom/anew@latest"
    "github.com/tomnomnom/unfurl@latest"
    "github.com/d3mondev/puredns/v2@latest"
    "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    "github.com/takshal/freq@latest"
)

for go_tool in "${GO_TOOLS[@]}"; do
    if ! command_exists "$(basename "$go_tool")"; then
        GO111MODULE=on go install -v "$go_tool" || print_error "Failed to install $go_tool."
    else
        print_info "$(basename "$go_tool") is already installed."
    fi
done

print_info "Installation completed. Verify tools manually if necessary."

PYTHON_TOOLS=(
    "git+https://github.com/s0md3v/Arjun.git"
    "git+https://github.com/tomnomnom/gf.git"
    "git+https://github.com/0xKayala/ParamSpider.git"
    "git+https://github.com/xnl-h4ck3r/xnLinkFinder.git"
    "git+https://github.com/xnl-h4ck3r/waymore.git"
    "git+https://github.com/vortexau/dnsvalidator.git"
    "git+https://github.com/Josue87/MetaFinder.git"
    "git+https://github.com/codingo/Interlace.git"
    "git+https://github.com/Josue87/EmailFinder.git"
    "git+https://github.com/dedupeio/dedupe.git"
    "git+https://github.com/s0md3v/uro.git"
    "git+https://github.com/xnl-h4ck3r/xnLinkFinder.git"
    "git+https://github.com/xnl-h4ck3r/waymore.git"
    "git+https://github.com/vortexau/dnsvalidator.git"
    "git+https://github.com/Josue87/MetaFinder.git"
    "git+https://github.com/codingo/Interlace.git"
    "git+https://github.com/Josue87/EmailFinder.git"
    "git+https://github.com/r0oth3x49/ghauri.git"
    "git+https://github.com/six2dez/dorks_hunter.git"

)

for py_tool in "${PYTHON_TOOLS[@]}"; do
    if ! command_exists "$(basename "$py_tool")"; then
        pipx install "$tool" || print_error "Failed to install $tool"
        pipx ensurepath
    else
        print_info "$(basename "$py_tool") is already installed."
    fi
done

pip3 install fake_useragent --break-system-packages
pip3 install google --break-system-packages
pip3 install tldextract --break-system-packages

cd ~
cd Tools
git clone https://github.com/trufflesecurity/trufflehog.git
cd trufflehog; 
sudo go install
