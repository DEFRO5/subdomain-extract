#!/usr/bin/env zsh

domain_file="url.txt"
output_file="url_extract.txt"

if [[ ! -f "$domain_file" ]]; then
    echo "File $domain_file not found!"
    exit 1
fi

> "$output_file"
while read -r domain; do
    if [[ -z "$domain" ]]; then
        continue
    fi

    echo "Processing domain: $domain"

    curl -s "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" \
        | jq .[].dns_names \
        | grep -Po "(([\\w.-]*)\\.([\\w]*)\\.([A-z]))\\w+" \
        | sort -u | tee -a "$output_file"

    curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=text&fl=original&collapse=urlkey" \
        | sed -e 's_https*://__' -e "s/\/.*//" \
        | sort -u | tee -a "$output_file"

    curl -s "https://jldc.me/anubis/subdomains/$domain" \
        | grep -Po "((http|https):\\/\\/)?(([\\w.-]*)\\.([\\w]*)\\.([A-z]))\\w+" \
        | sort -u | tee -a "$output_file"

    curl -s "https://crt.sh/?q=%25.$domain&output=json" \
        | jq -r '.[].name_value' \
        | sed 's/\\*\\.//g' \
        | sort -u | tee -a "$output_file"

    curl -s "https://api.threatminer.org/v2/domain.php?q=$domain&rt=5" \
        | jq -r '.results[]' \
        | grep -o "\\w.*" | tee -a "$output_file"

    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" \
        | awk -F',' '{print $1}' | tee -a "$output_file"

    curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/url_list?limit=100&page=1" \
        | grep -o '"hostname": *"[^"]*' \
        | sed 's/"hostname": "//' \
        | sort -u | tee -a "$output_file"

    curl -s "https://api.subdomain.center/?domain=$domain" \
        | jq -r '.[]' \
        | sort -u | tee -a "$output_file"

    nmap -sn --script hostmap-crtsh "$domain" \
        | awk -F'|' '$2 ~ /'$domain'/ {print $2}' \
        | tr -d ' ' | tee -a "$output_file"

done < "$domain_file"
