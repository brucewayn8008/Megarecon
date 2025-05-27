# 🔍 Mega Recon - Advanced Subdomain Discovery Tool

A comprehensive subdomain enumeration tool that combines multiple reconnaissance techniques including passive discovery, permutation generation, and mass DNS resolution to maximize subdomain coverage.

## 🚀 Features

- **Multi-Tool Integration** - Combines 10+ subdomain discovery tools
- **Subdomain Permutation** - Generates variations using altdns
- **Mass DNS Resolution** - Fast validation with massdns
- **Bruteforce Enumeration** - Dictionary-based discovery with puredns
- **Live Host Detection** - HTTP/HTTPS probing with httpx
- **Batch Processing** - Support for single domains or domain lists
- **Organized Output** - Results saved in structured directories
- **Colored Terminal Output** - Enhanced readability with status indicators

## 🛠️ Tools Used

### Core Enumeration Tools
- **subfinder** - Fast passive subdomain discovery
- **sublist3r** - Subdomain enumeration via search engines
- **assetfinder** - Find domains and subdomains related to a given domain
- **findomain** - Fast cross-platform subdomain enumerator
- **amass** - In-depth DNS enumeration and network mapping
- **github-subdomains** - Find subdomains via GitHub search
- **crt.sh** - Certificate transparency log queries

### Permutation & Resolution Tools
- **altdns** - Subdomain permutation and alteration
- **massdns** - High-performance DNS stub resolver
- **puredns** - Fast domain resolver and subdomain bruteforcing

### Validation Tools
- **httpx** - Fast and multi-purpose HTTP toolkit

## 📋 Installation

### Prerequisites
Make sure you have Go, Python3, and basic tools installed:

```bash
# Install Go (if not already installed)
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

### Tool Installation Commands

```bash
# Go-based tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/amass/v4/...@master
go install github.com/d3mondev/puredns/v2@latest
go install github.com/gwen001/github-subdomains@latest

# Python-based tools
pip3 install sublist3r altdns

# massdns (compile from source)
git clone https://github.com/blechschmidt/massdns.git
cd massdns && make
sudo cp bin/massdns /usr/local/bin/

# findomain
wget https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux-i386.zip
unzip findomain-linux-i386.zip
chmod +x findomain
sudo mv findomain /usr/local/bin/

# Other dependencies
sudo apt-get install jq curl
```

### Download Mega Recon

```bash
wget https://raw.githubusercontent.com/yourusername/mega-recon/main/mega_recon.sh
chmod +x mega_recon.sh
```

## 🎯 Usage

### Basic Usage

```bash
# Single domain
./mega_recon.sh example.com

# Multiple domains from file
./mega_recon.sh domains.txt
```

### Domain List Format
Create a text file with one domain per line:
```
example.com
target.com
testdomain.org
```

## 📊 Output Structure

For each domain, the script creates a results directory:

```
example.com_results/
├── example.com_subfinder.txt       # Subfinder results
├── example.com_sublist3r.txt       # Sublist3r results
├── example.com_assetfinder.txt     # Assetfinder results
├── example.com_findomain.txt       # Findomain results
├── example.com_amass.txt           # Amass results
├── example.com_github_subs.txt     # GitHub subdomains
├── example.com_crtsh.txt           # Certificate transparency
├── example.com_all_subs.txt        # Merged passive results
├── example.com_altdns_permutations.txt  # Generated permutations
├── example.com_altdns_resolved.txt      # Resolved permutations
├── example.com_massdns_results.txt      # Mass DNS results
├── example.com_massdns_resolved.txt     # Resolved via massdns
├── example.com_puredns.txt         # Bruteforce results
├── example.com_final_subs.txt      # All discovered subdomains
└── example.com_alive.txt           # Live/responsive subdomains
```

## 🔧 Configuration

### GitHub Token
Replace the GitHub token in the script with your own:

```bash
GITHUB_TOKEN="your_github_token_here"
```

To generate a GitHub token:
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with `public_repo` scope
3. Replace the token in the script

### Custom Wordlists
The script automatically downloads wordlists, but you can customize them:

- **altdns wordlist**: Modify the `altdns_words.txt` generation section
- **puredns wordlist**: Change the SecLists URL to your preferred wordlist

### Port Configuration
Default ports probed by httpx: `80,443,8080,8000,8888,9000,9443,8443`

Modify the httpx command to change ports:
```bash
httpx -silent -p 80,443,8080,8000,8888,9000,9443,8443
```

## 🎨 Sample Output

```
====================================
[*] Recon for example.com
====================================
[*] Running Subfinder...
[*] Running Sublist3r...
[*] Running Assetfinder...
[*] Running Findomain...
[*] Running Amass passive enumeration...
[*] Running GitHub Subdomains...
[*] Querying crt.sh...
[*] Merging and deduplicating discovered subdomains...

==== SUBDOMAIN PERMUTATION PHASE ====
[*] Generating subdomain permutations with altdns...
[*] Performing mass DNS resolution with massdns...
[*] Bruteforce DNS resolution with puredns...
[*] Probing live subdomains with httpx...

==== SUMMARY FOR example.com ====
Total subdomains discovered: 1247
Live subdomains found: 89

[✅] Done with example.com!
[📁] Results saved in: example.com_results/
[📁] Live subdomains: example.com_results/example.com_alive.txt
[📁] All subdomains: example.com_results/example.com_final_subs.txt
```

## ⚡ Performance Tips

1. **Parallel Processing**: Run multiple instances for different domains
2. **Resource Management**: The script includes timeouts for long-running tools
3. **DNS Resolvers**: Uses public DNS resolvers for better resolution rates
4. **Wordlist Optimization**: Customize wordlists based on your target

## 🔒 Security Considerations

- Only use this tool on domains you own or have explicit permission to test
- Be mindful of rate limits on external APIs
- Consider using VPN/proxy for large-scale enumeration
- GitHub token should have minimal required permissions

## 🐛 Troubleshooting

### Common Issues

**Tool not found errors:**
```bash
# Check if tools are in PATH
echo $PATH
# Add Go bin to PATH if missing
export PATH=$PATH:$(go env GOPATH)/bin
```

**Permission denied:**
```bash
chmod +x mega_recon.sh
```

**DNS resolution issues:**
- Check internet connectivity
- Verify DNS resolver accessibility
- Consider using different DNS resolvers

**Empty results:**
- Verify domain spelling
- Check if domain actually exists
- Some tools may be rate-limited

## 📈 Advanced Usage

### Custom DNS Resolvers
Replace the default resolvers.txt with your own:
```bash
# Create custom resolvers file
echo "8.8.8.8" > custom_resolvers.txt
echo "1.1.1.1" >> custom_resolvers.txt
# Update script to use custom_resolvers.txt
```

### Integration with Other Tools
Pipe results to other security tools:
```bash
# Port scanning with nmap
cat example.com_alive.txt | nmap -iL - -p 80,443

# Directory bruteforcing with ffuf
cat example.com_alive.txt | ffuf -w wordlist.txt -u FUZZ/HFUZZ
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This tool is for educational and authorized security testing purposes only. Users are responsible for ensuring they have proper authorization before scanning any domains. The authors are not responsible for any misuse of this tool.

## 🙏 Acknowledgments

- ProjectDiscovery team for excellent tools like subfinder and httpx
- All the amazing security researchers who created the integrated tools
- SecLists project for comprehensive wordlists
- Certificate transparency logs for passive reconnaissance

---

**Happy Hunting! 🎯**
