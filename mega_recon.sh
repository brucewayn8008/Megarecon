#!/bin/bash

# Mega Recon - Enhanced Subdomain Discovery Tool
# Usage: ./mega_recon.sh <domain> OR ./mega_recon.sh <domain_list.txt>

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GitHub Token (replace with your own)
GITHUB_TOKEN=""

# Function to print colored output
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✅]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[📁]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Check if input is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <domain> OR $0 <domain_list.txt>${NC}"
    exit 1
fi

INPUT="$1"

# Check if input is a file or single domain
if [ -f "$INPUT" ]; then
    DOMAINS=$(cat "$INPUT")
else
    DOMAINS="$INPUT"
fi

# Process each domain
for DOMAIN in $DOMAINS; do
    echo ""
    echo "===================================="
    print_header "[*] Recon for $DOMAIN"
    echo "===================================="
    
    # Create directory for domain results
    mkdir -p "$DOMAIN"_results
    cd "$DOMAIN"_results
    
    # Subfinder
    print_status "Running Subfinder..."
    if command -v subfinder &> /dev/null; then
        subfinder -d "$DOMAIN" -silent -o "${DOMAIN}_subfinder.txt"
    else
        echo "Subfinder not found, skipping..."
    fi
    
    # Sublist3r
    print_status "Running Sublist3r..."
    if command -v sublist3r &> /dev/null; then
        sublist3r -d "$DOMAIN" -o "${DOMAIN}_sublist3r.txt" 2>/dev/null
    else
        echo "Sublist3r not found, skipping..."
    fi
    
    # Assetfinder
    print_status "Running Assetfinder..."
    if command -v assetfinder &> /dev/null; then
        assetfinder --subs-only "$DOMAIN" | tee "${DOMAIN}_assetfinder.txt"
    else
        echo "Assetfinder not found, skipping..."
    fi
    
    # Findomain
    print_status "Running Findomain..."
    if command -v findomain &> /dev/null; then
        findomain --quiet -t "$DOMAIN" | tee "${DOMAIN}_findomain.txt"
    else
        echo "Findomain not found, skipping..."
    fi
    
    # Amass (passive)
    print_status "Running Amass passive enumeration..."
    if command -v amass &> /dev/null; then
        timeout 300 amass enum -passive -norecursive -noalts -d "$DOMAIN" -o "${DOMAIN}_amass.txt"
    else
        echo "Amass not found, skipping..."
    fi
    
    # GitHub-subdomains
    print_status "Running GitHub Subdomains..."
    if command -v github-subdomains &> /dev/null; then
        github-subdomains -d "$DOMAIN" -t "$GITHUB_TOKEN" -o "${DOMAIN}_github_subs.txt"
    else
        echo "GitHub-subdomains not found, skipping..."
    fi
    
    # crt.sh
    print_status "Querying crt.sh..."
    curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > "${DOMAIN}_crtsh.txt" 2>/dev/null
    
    # Merge all discovered subdomains
    print_status "Merging and deduplicating discovered subdomains..."
    cat "${DOMAIN}"_*.txt 2>/dev/null | grep -v "^$" | sort -u > "${DOMAIN}_all_subs.txt"
    
    # Subdomain Permutation Section
    echo ""
    print_header "==== SUBDOMAIN PERMUTATION PHASE ===="
    
    # Generate permutations with altdns
    print_status "Generating subdomain permutations with altdns..."
    if command -v altdns &> /dev/null; then
        # Create a wordlist for altdns (you can customize this)
        cat > altdns_words.txt << EOF
dev
test
stage
staging
prod
production
api
www
mail
ftp
admin
blog
shop
store
portal
app
mobile
secure
vpn
remote
backup
old
new
demo
beta
alpha
v1
v2
web
site
internal
external
public
private
tmp
temp
EOF
        
        altdns -i "${DOMAIN}_all_subs.txt" -o "${DOMAIN}_altdns_permutations.txt" -w altdns_words.txt -r -s "${DOMAIN}_altdns_resolved.txt"
        
        # Clean up
        rm -f altdns_words.txt
    else
        echo "altdns not found, skipping permutation generation..."
    fi
    
    # Mass DNS resolution with massdns
    print_status "Performing mass DNS resolution with massdns..."
    if command -v massdns &> /dev/null; then
        # Combine original subdomains with permutations
        cat "${DOMAIN}_all_subs.txt" "${DOMAIN}_altdns_permutations.txt" 2>/dev/null | sort -u > "${DOMAIN}_combined_subs.txt"
        
        # Download resolvers if not present
        if [ ! -f "resolvers.txt" ]; then
            print_status "Downloading DNS resolvers..."
            curl -s https://raw.githubusercontent.com/blechschmidt/massdns/master/lists/resolvers.txt > resolvers.txt
        fi
        
        # Run massdns
        massdns -r resolvers.txt -t A -o S -w "${DOMAIN}_massdns_results.txt" "${DOMAIN}_combined_subs.txt"
        
        # Extract resolved domains
        grep -E "^[^;]" "${DOMAIN}_massdns_results.txt" | cut -d' ' -f1 | sed 's/\.$//' | sort -u > "${DOMAIN}_massdns_resolved.txt"
        
        # Merge all resolved subdomains
        cat "${DOMAIN}_all_subs.txt" "${DOMAIN}_altdns_resolved.txt" "${DOMAIN}_massdns_resolved.txt" 2>/dev/null | sort -u > "${DOMAIN}_all_resolved_subs.txt"
    else
        echo "massdns not found, using original subdomain list..."
        cp "${DOMAIN}_all_subs.txt" "${DOMAIN}_all_resolved_subs.txt"
    fi
    
    # Bruteforce with puredns (if available)
    print_status "Bruteforce DNS resolution with puredns..."
    if command -v puredns &> /dev/null; then
        # Download a wordlist if not present
        if [ ! -f "subdomains.txt" ]; then
            print_status "Downloading subdomain wordlist..."
            curl -s https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-110000.txt > subdomains.txt
        fi
        
        puredns bruteforce subdomains.txt "$DOMAIN" -r resolvers.txt --write "${DOMAIN}_puredns.txt"
        
        # Merge puredns results
        cat "${DOMAIN}_all_resolved_subs.txt" "${DOMAIN}_puredns.txt" 2>/dev/null | sort -u > "${DOMAIN}_final_subs.txt"
    else
        echo "puredns not found, using resolved subdomains..."
        cp "${DOMAIN}_all_resolved_subs.txt" "${DOMAIN}_final_subs.txt"
    fi
    
    # Probe alive domains with httpx
    print_status "Probing live subdomains with httpx..."
    if command -v httpx &> /dev/null; then
        cat "${DOMAIN}_final_subs.txt" | httpx -silent -p 80,443,8080,8000,8888,9000,9443,8443 -mc 200,201,301,302,403 -fc 404 > "${DOMAIN}_alive.txt"
    else
        echo "httpx not found, skipping alive check..."
        cp "${DOMAIN}_final_subs.txt" "${DOMAIN}_alive.txt"
    fi
    
    # Generate summary
    echo ""
    print_header "==== SUMMARY FOR $DOMAIN ===="
    echo "Total subdomains discovered: $(wc -l < "${DOMAIN}_final_subs.txt" 2>/dev/null || echo "0")"
    echo "Live subdomains found: $(wc -l < "${DOMAIN}_alive.txt" 2>/dev/null || echo "0")"
    
    print_success "Done with $DOMAIN!"
    print_info "Results saved in: ${DOMAIN}_results/"
    print_info "Live subdomains: ${DOMAIN}_results/${DOMAIN}_alive.txt"
    print_info "All subdomains: ${DOMAIN}_results/${DOMAIN}_final_subs.txt"
    
    # Go back to parent directory
    cd ..
    
    echo ""
done

print_success "Mega recon finished for all domains!"
echo ""
print_header "🛠️  Tools used (if available):"
echo "   • subfinder, sublist3r, assetfinder, findomain"
echo "   • amass, github-subdomains, crt.sh"
echo "   • altdns (permutations), massdns (mass resolution)"
echo "   • puredns (bruteforce), httpx (alive check)"
echo ""
print_header "📋 Installation commands for missing tools:"
echo "   go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
echo "   go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
echo "   pip3 install sublist3r"
echo "   go install github.com/tomnomnom/assetfinder@latest"
echo "   pip3 install altdns"
echo "   git clone https://github.com/blechschmidt/massdns.git && cd massdns && make"
echo "   go install github.com/d3mondev/puredns/v2@latest"
