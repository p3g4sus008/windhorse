#!/bin/bash

# Configuration variables
aquatoneThreads=5
subdomainThreads=10
dirsearchThreads=50
dirsearchWordlist=~/tools/dirsearch/db/dicc.txt
massdnsWordlist=~/tools/SecLists/Discovery/DNS/clean-jhaddix-dns.txt
chromiumPath=/usr/bin/chromium

# Colors for output
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

# Help function
usage() {
    echo -e "${green}Usage:${reset}"
    echo "  -h/--help                Show help"
    echo "  -p <project_name>        Specify project name"
    echo "  -d <domain>              Specify a single domain"
    echo "  -l <domain_list>         Specify a file containing domain list"
    echo "  -o <output_dir>          Specify output directory"
    echo
    echo -e "${green}Examples:${reset}"
    echo "  windhorse -d example.com -p example_red_team_recon -o /home/user/Desktop/Example/"
    echo "  windhorse -l /path/to/domainlist.txt -p example_project -o /home/user/Desktop/Example/"
}

# Subdomain enumeration
subdomain_enum() {
    domain=$1
    temp_dir="$local_dir/$Project/temp/subdomains/$domain"
    mkdir -p "$temp_dir"
    mkdir -p "$local_dir/$Project/$domain"

    echo -e "${green}Starting subdomain enumeration for $domain...${reset}"
    sublist3r -d "$domain" -o "$temp_dir/sublist3r_temp_subdomains.txt" 2>/dev/null
    subfinder -d "$domain" -o "$temp_dir/subfinder_temp_subdomains.txt" 2>/dev/null
    assetfinder --subs-only "$domain" >> "$temp_dir/assetfinder_temp_subdomains.txt" 2>/dev/null
    curl -s "https://api.certspotter.com/v1/issuances?domain=$domain" | jq '.[].dns_names[]' | sed 's/\"//g; s/\*\.//g' | sort -u | grep "$domain" >> "$temp_dir/certspotter_temp_subdomains.txt"

    # Consolidate results
    cat "$temp_dir/"*_temp_subdomains.txt | sort -u > "$temp_dir/$domain_subdomains.txt"
    cp "$temp_dir/$domain_subdomains.txt" "$local_dir/$Project/$domain/subdomains.txt"
}

# Check live domains
live_domain() {
    domain=$1
    temp_dir="$local_dir/$Project/temp/hostalive/$domain"
    mkdir -p "$temp_dir"

    echo -e "${green}Probing live hosts for $domain...${reset}"
    cat "$local_dir/$Project/$domain/subdomains.txt" | httprobe -c 50 -t 3000 > "$temp_dir/live_subdomains.txt"

    # Consolidate live subdomains
    sort -u "$temp_dir/live_subdomains.txt" | sed 's/http[s]*:\/\///g' > "$local_dir/$Project/$domain/live-subdomains.txt"
    echo -e "${yellow}Found $(wc -l < "$local_dir/$Project/$domain/live-subdomains.txt") live subdomains.${reset}"
}

# Aquatone snapshot
snapshot() {
    domain=$1
    echo -e "${green}Taking Aquatone snapshots for $domain...${reset}"
    cat "$local_dir/$Project/$domain/live-subdomains.txt" | aquatone -out "$local_dir/$Project/$domain/snapshot" -silent
}

# URL scraping
url_scrap() {
    domain=$1
    temp_dir="$local_dir/$Project/temp/urls/$domain"
    mkdir -p "$temp_dir"
    mkdir -p "$local_dir/$Project/$domain/urls"

    echo -e "${green}Scraping URLs for $domain using waybackurls...${reset}"
    cat "$local_dir/$Project/$domain/live-subdomains.txt" | waybackurls > "$temp_dir/waybackurls.txt"
    cp "$temp_dir/waybackurls.txt" "$local_dir/$Project/$domain/urls/"

    # Extract specific URLs
    sort -u "$temp_dir/waybackurls.txt" | unfurl --unique keys > "$temp_dir/paramlist.txt"
    sort -u "$temp_dir/waybackurls.txt" | grep -P "\w+\.js(\?|$)" > "$temp_dir/jsurls.txt"
    sort -u "$temp_dir/waybackurls.txt" | grep -P "\w+\.php(\?|$)" > "$temp_dir/phpurls.txt"
    sort -u "$temp_dir/waybackurls.txt" | grep -P "\w+\.aspx(\?|$)" > "$temp_dir/aspxurls.txt"
    sort -u "$temp_dir/waybackurls.txt" | grep -P "\w+\.jsp(\?|$)" > "$temp_dir/jspurls.txt"

    echo -e "${green}Saved extracted URLs to respective files.${reset}"
}

# Run other tools
other_tools() {
    domain=$1
    mkdir -p "$local_dir/$Project/$domain/reconftw"
    mkdir -p "$local_dir/$Project/$domain/subdomz"

    echo -e "${green}Running additional tools for $domain...${reset}"
    reconftw -d "$domain" -r --deep -o "$local_dir/$Project/$domain/reconftw"
    subdomz -d "$domain" -o "$local_dir/$Project/$domain/subdomz"
}

# XSS Testing
xss() {
    domain=$1
    temp_dir="$local_dir/$Project/temp/urls/$domain"
    echo -e "${green}Testing for XSS vulnerabilities on $domain...${reset}"
    cat "$temp_dir/waybackurls.txt" | dalfox pipe > "$local_dir/$Project/$domain/xss_results.txt"
}

# Main function
main() {
    while getopts ":p:d:l:o:h" opt; do
        case $opt in
            p) Project=$OPTARG ;;
            d) single_domain=$OPTARG ;;
            l) domain_list=$OPTARG ;;
            o) local_dir=$OPTARG ;;
            h) usage; exit ;;
            *) echo "Invalid option"; usage; exit 1 ;;
        esac
    done

    if [[ -z $Project || -z $local_dir ]]; then
        echo -e "${red}Error: Project name and output directory are required!${reset}"
        usage
        exit 1
    fi

    mkdir -p "$local_dir/$Project/temp"
    mkdir -p "$local_dir/$Project"

    if [[ -n $single_domain ]]; then
        subdomain_enum "$single_domain"
        live_domain "$single_domain"
        snapshot "$single_domain"
        url_scrap "$single_domain"
        xss "$single_domain"
        other_tools "$single_domain"
    elif [[ -n $domain_list ]]; then
        while IFS= read -r domain; do
            subdomain_enum "$domain"
            live_domain "$domain"
            snapshot "$domain"
            url_scrap "$domain"
            xss "$domain"
            other_tools "$domain"
        done < "$domain_list"
    else
        echo -e "${red}Please provide a domain or a domain list.${reset}"
        usage
        exit 1
    fi
}

main "$@"
