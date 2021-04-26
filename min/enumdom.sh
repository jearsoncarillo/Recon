#!/bin/bash

TARGET=$1
index=$(xxd -l3 -ps /dev/urandom)
subdomain=$(xxd -l3 -ps /dev/urandom)
ipaddr=$(xxd -l3 -ps /dev/urandom)

function show_banner
{
    echo -e "╦═╗┌─┐┌─┐┌─┐┌┐┌ ┌─┐┬ ┬
╠╦╝├┤ │  │ ││││ └─┐├─┤
╩╚═└─┘└─┘└─┘┘└┘o└─┘┴ ┴
  Domain Enumeration\n"
}

function usage
{
    echo "Enumerates target domain for subdomains and converts
dns names into IP addresses.

Usage:
enumdom.sh [DOMAIN]

Example:
enumdom.sh facebook.com"
}

function check_args
{
    if [ -z $TARGET ]; then
        usage
        exit
    fi

    if [[ ! $TARGET =~ [A-Za-z0-9_\.-]$ ]]; then
        usage
        exit
    fi
}

function index_mapping
{
    echo -e "[+] Downloading index of $TARGET.."
    wget $TARGET -O /tmp/$index.html -q
    sleep .75
}

function scrape_subdomain
{
    echo -e "[+] Scraping for subdomains.."
    grep -o '[A-Za-z0-9_\.-]'*$TARGET /tmp/$index.html \
    | sort -u >> /tmp/$subdomain
    sleep .75
}

function get_ip_start
{
    echo -e "[+] Converting domains to ip addresses..\n"
}

function get_ip_end
{
    echo -e "\n[+] Done."
}

function get_ipaddress 
{
    sleep .25
    for i in $(cat /tmp/$subdomain); do
        host $i
    done \
        | grep "has address" | awk '{print $4}' | sort -u
}

function save_file
{
    read -p "[*] Do you want to save to file?[y/N] " getopt
    case $getopt in
        [yY]|[yY][eE][sS])
            get_ip_start
            get_ipaddress | tee -a ./$TARGET-hosts.txt
	    echo -e "\n[+] Saved file on $(pwd)/$TARGET-hosts.txt"
            ;;
        [nN]|[nN][oO])
            get_ip_start
            get_ipaddress
	    get_ip_end
            ;;
        *)
            save_file
            ;;
    esac
}

function main
{
    show_banner
    check_args
    index_mapping
    scrape_subdomain
    save_file
}

main
