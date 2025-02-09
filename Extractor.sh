#!/bin/bash

xfce4-terminal --hold -e "bash -c 'curl -sL https://raw.githubusercontent.com/DEFRO5/subdomain-extract/refs/heads/main/one-liners.sh | bash'" &
xfce4-terminal --hold -e "bash -c 'amass enum -brute -df url.txt'" &
xfce4-terminal --hold -e "bash -c 'anubis -f url.txt -n -r -s -q 20 -o anubis.txt'" &
xfce4-terminal --hold -e "bash -c 'bbot -t url.txt -f safe -m bypass403 --output-dir bbot_output --output-module subdomains'" &
xfce4-terminal --hold -e "bash -c 'knockpy -f url.txt --recon --bruteforce | awk \"!/^(http|https|cert)/ {print \$1}\" | tee knockpy.txt'" &
xfce4-terminal --hold -e "bash -c 'subfinder -dL url.txt -all -recursive -o subfinder.txt'" &
xfce4-terminal --hold -e "bash -c 'sublist3r -d domain -t 20 -o sublist3r.txt'" &
xfce4-terminal --hold -e "bash -c 'SubDomainizer -l url.txt -k -o subDomainizer.txt'" &
