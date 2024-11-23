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

#--------------------#
# System Preparation #
#--------------------#
print_info "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y || print_error "Failed to update/upgrade system."

echo -e "${GREEN}---------------------Start Installing Kali Linux tools---------------------\n\n"
sudo apt-get install pipx -y
sudo apt-get install golang -y
sudo apt-get install eyewitness -y
sudo apt-get install figlet -y
sudo apt-get install subfinder -y
sudo apt-get install assetfinder -y
sudo apt-get install dnsgen -y
sudo apt-get install massdns -y
sudo apt-get install httprobe -y
sudo apt-get install amass -y
sudo apt-get install -y ffuf
sudo apt-get install -y chromium 
sudo apt-get install dirsearch -y
sudo apt-get install wpscan -y
sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y ruby-full
sudo apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev
sudo apt-get install -y libldns-dev
sudo apt-get install -y python3-pip
sudo apt-get install -y git
sudo apt-get install -y rename
sudo apt-get install -y xargs
sudo apt-get install -y dalfox
sudo apt-get install -y rling
sudo apt-get install -y gospider
sudo apt-get install -y curl
sudo apt-get install -y unzip
sudo apt-get install -y wget
sudo apt-get install -y cargo
sudo apt-get install -y rustup
sudo apt-get install -y reling

echo -e "${GREEN} Windhorse globalisation..."
sudo cp windhorse.sh /usr/bin/windhorse
#-------------------------#
# Install Security Tools  #
#-------------------------#
echo -e "${GREEN}---------------------Start Installing GitHub tools---------------------\n\n\n"
TOOLBOX_DIR="$HOME/toolbox"
mkdir -p "$TOOLBOX_DIR"
cd "$TOOLBOX_DIR" || exit

git clone https://github.com/s0md3v/XSStrike.git 
cd XSStrike
sudo pip3 install -r requirements.txt --break-system-packages
cd ..

#--install tplmap---SSTI-----
git clone https://github.com/epinna/tplmap.git
cd tplmap
sudo pip3 install -r requirements.txt --break-system-packages
cd ..

print_info "Installing additional tools..."
git clone https://github.com/blechschmidt/massdns.git
cd massdns || exit
make && sudo make install || print_error "Failed to install MassDNS."
cd ..
print_info "Installing Nmap Automator..."
git clone https://github.com/21y4d/nmapAutomator.git

git clone https://github.com/s0md3v/Arjun.git
git clone https://github.com/tomnomnom/gf.git
git clone https://github.com/0xKayala/ParamSpider.git
git clone https://github.com/xnl-h4ck3r/xnLinkFinder.git
git clone https://github.com/xnl-h4ck3r/waymore.git
git clone https://github.com/vortexau/dnsvalidator.git
git clone https://github.com/Josue87/MetaFinder.git
git clone https://github.com/codingo/Interlace.git
git clone https://github.com/Josue87/EmailFinder.git
git clone https://github.com/dedupeio/dedupe.git
print_info "Cloning SecLists..."
git clone https://github.com/danielmiessler/SecLists.git || print_error "Failed to clone SecLists."
git clone https://github.com/1ndianl33t/Gf-Patterns.git

echo "${GREEN}Start Installing Subdomain Enumeration Tools\n\n\n"
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

print_info "Installing Sublist3r..."
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r || exit
sudo pip3 install -r requirements.txt --break-system-packages || print_error "Failed to install Sublist3r dependencies."
sudo pip3 install requests
sudo pip3 install dnspython
sudo pip3 install argparse
sudo ln -s "$(pwd)/sublist3r.py" /usr/bin/sublist3r
cd ..

print_info "Installing Findomain..."
git clone https://github.com/findomain/findomain.git
cd findomain || exit
cargo build --release
sudo cp target/release/findomain /usr/bin/
cd ..

#-------------------------#
# Web Scraping Tools      #
#-------------------------#

print_info "Installing gau (Get All URLs)..."
wget -q "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz"
tar -xf gau_2.2.4_linux_amd64.tar.gz
sudo mv gau /usr/bin/

print_info "Installing Aquatone for snapshots..."
wget -q "https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip"
unzip -q aquatone_linux_amd64_1.7.0.zip
sudo mv aquatone /usr/bin/

print_info "Installing Waybackurls..."
wget -q "https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz"
tar -xf waybackurls-linux-amd64-0.1.0.tgz
sudo mv waybackurls /usr/bin/

#------------------------#
# Install Go Tools       #
#------------------------#
print_info "Installing Go Lang"
sudo apt-get install golang -y
GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
GO111MODULE=on go install -v github.com/owasp-amass/amass/v3/...@master
GO111MODULE=on go install github.com/tomnomnom/assetfinder@latest
GO111MODULE=on go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
GO111MODULE=on go install -v github.com/hakluke/haktrails@latest
GO111MODULE=on go install github.com/lc/gau/v2/cmd/gau@latest
GO111MODULE=on go install github.com/gwen001/github-subdomains@latest
GO111MODULE=on go install github.com/gwen001/gitlab-subdomains@latest
GO111MODULE=on go install -v github.com/glebarez/cero@latest
GO111MODULE=on go install github.com/incogbyte/shosubgo@latest
GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
GO111MODULE=on go install -v github.com/tomnomnom/anew@latest
GO111MODULE=on go install github.com/tomnomnom/unfurl@latest
GO111MODULE=on go install github.com/d3mondev/puredns/v2@latest
GO111MODULE=on go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@lates
go install github.com/takshal/freq@latest
git clone https://github.com/blechschmidt/massdns.git && cd massdns && make && sudo make install && cd ..

git clone https://github.com/KathanP19/Gxss.git
cd Gxss
go install
cd ..

git clone https://github.com/tomnomnom/gf.git
cd gf
go install
cd ..
#-------------------------#
# Install Python Tools    #
#-------------------------#
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
)

print_info "Installing Python tools..."
for tool in "${PYTHON_TOOLS[@]}"; do
    pipx install "$tool" || print_error "Failed to install $tool"
done


#-------------------------#
# Additional Installations #
#-------------------------#


print_info "Installing Dorks Hunter..."
pip3 install fake_useragent google tldextract || print_error "Failed to install Dorks Hunter dependencies."

print_info "Cloning and installing Trufflehog..."
git clone https://github.com/trufflesecurity/trufflehog.git
cd trufflehog || exit
sudo go install || print_error "Failed to install Trufflehog."
cd ..



#install uro

pipx install git+https://github.com/s0md3v/uro.git
pipx ensurepath
#-----------------#
# Summary         #
#-----------------#
print_info "Installation completed. Verify tools manually if necessary."

#>>>>>>>>>>>>>>>>>>>>>recon tool reconftw<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#----xnLinkFinder-----------------
pipx install git+https://github.com/xnl-h4ck3r/xnLinkFinder.git
pipx ensurepath

#----waymore-----------------
pipx install git+https://github.com/xnl-h4ck3r/waymore.git
pipx ensurepath

#----dnsvalidator -----------------
pipx install git+https://github.com/vortexau/dnsvalidator.git 
pipx ensurepath

#----metafinder  -----------------
pipx install git+https://github.com/Josue87/MetaFinder.git
pipx ensurepath

#----interlace  -----------------
pipx install git+https://github.com/codingo/Interlace.git
pipx ensurepath

#----emailfinder  -----------------
pipx install git+https://github.com/Josue87/EmailFinder.git
pipx ensurepath

#----ripgen -----------------
sudo apt install cargo -y
sudo apt install rustup -y
sudo cargo install ripgen

#----ghauri -----------------
pipx install git+https://github.com/r0oth3x49/ghauri.git
pipx ensurepath

#----porch-pirate  -----------------
pipx install git+https://github.com/six2dez/dorks_hunter.git
pipx ensurepath

#------fix issue of dorks hunter------------------------
pip3 install fake_useragent --break-system-packages
pip3 install google --break-system-packages
pip3 install tldextract --break-system-packages

#------trufflehog------------------------
cd ~
cd Tools
git clone https://github.com/trufflesecurity/trufflehog.git
cd trufflehog; 
sudo go install

#---------------------------------------------------------------------------------------
