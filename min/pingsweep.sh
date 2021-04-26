#!/bin/bash

SUBNET=$1
file=$(xxd -l3 -ps /dev/urandom)

function show_banner
{
    echo -e "╦═╗┌─┐┌─┐┌─┐┌┐┌ ┌─┐┬ ┬
╠╦╝├┤ │  │ ││││ └─┐├─┤
╩╚═└─┘└─┘└─┘┘└┘o└─┘┴ ┴
    Subnet Sweeper\n"
}

function usage
{
    echo "Sweeps the target subnet for live hosts.

Usage:
pingsweep.sh [SUBNET]

Example:
pingsweep.sh 172.10.10.0"
}

function check_args
{
    if [ -z $SUBNET ]; then
        usage
        exit
    fi
}

function ping_sweep_nosave
{
    if [[ $SUBNET =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0$ ]]; then
        echo $SUBNET | awk -F'.' '{print $1,$2,$3,$4}' | tr ' ' \\n > /tmp/$file
	
        for i in $(cat /tmp/$file); do 
            if [ $i -gt 255 ]; then 
		usage
                rm -rf /tmp/$file
                exit
            fi
        done
       
        rm -rf /tmp/$file
    	
        SUBNET=$(echo $SUBNET | cut -d'.' -f1-3)
	for i in {1..254}; do
            ping -c1 $SUBNET.$i | tr \\n ' ' \
                | awk '/1 received/ {print $2}' \
		| xargs -I % echo 'Host % is up' &
        done
    else
        usage
        exit
    fi
}

function ping_sweep_savefile
{
    if [[ $SUBNET =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0$ ]]; then
        echo $SUBNET | awk -F'.' '{print $1,$2,$3,$4}' | tr ' ' \\n > /tmp/$file
        for i in $(cat /tmp/$file); do 
            if [ $i -gt 255 ]; then 
                usage
		rm -rf /tmp/$file
                exit
            fi
        done
       
        rm -rf /tmp/$file
    	
        SUBNET=$(echo $SUBNET | cut -d'.' -f1-3)
        for i in {1..254}; do 
            ping -c1 $SUBNET.$i | tr \\n ' ' \
                | awk '/1 received/ {print $2}' \
                | xargs -I % echo 'Host % is up' &
        done
    else
        usage
	exit
    fi
}

function sweep_start
{
    echo -e "[+] Sweeping target subnet.. $SUBNET..\n"
}

function sweep_end
{
    echo -e "\n[+] Saved on $(pwd)/Livehosts.txt."
}

function save_file
{
    read -p "[*] Do you want to save to file?[y/N] " getopt
    case $getopt in
        [yY]|[yY][eE][sS])
            sweep_start
            ping_sweep_savefile | tee -a ./Live-hosts.txt
            sweep_end
            ;;
        [nN]|[nN][oO])
            sweep_start
            ping_sweep_nosave
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
    save_file
}

main
