#!/bin/bash

TARGET=$1
PORT=$2
FILE=$(xxd -l3 -ps /dev/urandom)

function show_banner
{
    echo -e "╦═╗┌─┐┌─┐┌─┐┌┐┌ ┌─┐┬ ┬
╠╦╝├┤ │  │ ││││ └─┐├─┤
╩╚═└─┘└─┘└─┘┘└┘o└─┘┴ ┴
     Port Scanner\n"
}

function usage
{
    echo "Scans the target for open ports from 1 to specified port number.

Usage:
portscan.sh [TARGET_IP] [PORT_NUMBER]

Example:
portscan.sh 172.20.20.10 65535"
}

function check_ip
{
    if [[ $TARGET =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo $TARGET | awk -F'.' '{print $1,$2,$3,$4}' | tr ' ' \\n > /tmp/$FILE

        for i in $(cat /tmp/$FILE); do
            if [ $i -gt 255 ]; then
                usage
                rm -rf /tmp/$FILE
                exit
            fi
        done

        rm -rf /tmp/$FILE
    fi
}

function check_port
{
    if [[ $PORT =~ ^[0-9]{1,5}$ ]]; then
    	echo -n ""
    else
        usage
        exit
    fi
}

function check_args
{
    
    if [ -z $TARGET ] ; then
	usage
	exit

    elif [ -z $TARGET ] && [ -z $PORT ]; then
	usage
        exit

    elif [ -z $PORT ]; then
        PORT=2
	check_ip
    else
	check_ip
        check_port
    fi
}

function ncat_scanner
{
    for i in `seq 1 $PORT`; do 
	(nc -w 1 -zv $TARGET $i 2>&1 | grep -i 'connected' | awk -F':' '{print $3}' \
        | sed s/\\.// | xargs -I % echo 'Port % is open' &)
    done
}

function nc_scanner
{
    for i in `seq 1 $PORT`; do
       (/usr/bin/nc -w 1 -zv $TARGET $i 2>&1 | grep -v 'route\|Connection' \
       | awk -F' ' '{print $3}' | xargs -I % echo 'Port % is open' &)
    done
}

function bash_scanner
{
    for i in `seq 1 $PORT`; do ((echo > /dev/tcp/$TARGET/$i) > /dev/null \
        2>&1 && echo "Port $i is open" | grep -v 'route' &)
    done
}

function scan_start
{
    echo "[+] Started Scanning at $(date '+%H:%M:%S')"
    echo -e "[+] Initiating port scan on target $TARGET..\n"
}

function scan_end
{
    echo -e "\n[+] Scanning Stopped at $(date '+%H:%M:%S')"
}

function save_notif
{
    echo -e "[+] Saved on $(pwd)/$TARGET-ports.txt."
}

function scanner_select_savefile
{
    if [ -z $(which ncat) ]; then
        if [ -z $(which nc) ]; then
            scan_start
            bash_scanner | tee -a ./$TARGET-ports.txt
            scan_end
            save_notif
        fi

	scan_start
        nc_scanner | tee -a ./$TARGET-ports.txt
        scan_end
        save_notif
    else
        scan_start
        ncat_scanner | tee -a ./$TARGET-ports.txt
        scan_end
        save_notif
    fi
   
}

function scanner_select_nosave
{
    if [ -z $(which ncat) ]; then
        if [ -z $(which nc) ]; then
            scan_start
            bash_scanner
            scan_end
        fi

	scan_start
        nc_scanner
        scan_end
    else
        scan_start
        ncat_scanner
        scan_end
    fi
}

function save_file
{
    read -p "[*] Do you want to save to file?[y/N] " getopt
    case $getopt in
        [yY]|[yY][eE][sS])
            scanner_select_savefile
            ;;
        [nN]|[nN][oO])
            echo
            scanner_select_nosave
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
