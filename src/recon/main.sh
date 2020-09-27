#!/bin/bash

function show_banner
{
    banner='
 ██▀███  ▓█████  ▄████▄   ▒█████   ███▄    █        ██████  ██░ ██
▓██ ▒ ██▒▓█   ▀ ▒██▀ ▀█  ▒██▒  ██▒ ██ ▀█   █      ▒██    ▒ ▓██░ ██▒
▓██ ░▄█ ▒▒███   ▒▓█    ▄ ▒██░  ██▒▓██  ▀█ ██▒     ░ ▓██▄   ▒██▀▀██░
▒██▀▀█▄  ▒▓█  ▄ ▒▓▓▄ ▄██▒▒██   ██░▓██▒  ▐▌██▒       ▒   ██▒░▓█ ░██
░██▓ ▒██▒░▒████▒▒ ▓███▀ ░░ ████▓▒░▒██░   ▓██░ ██▓ ▒██████▒▒░▓█▒░██▓
░ ▒▓ ░▒▓░░░ ▒░ ░░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ▒▓▒ ▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒
  ░▒ ░ ▒░ ░ ░  ░  ░  ▒     ░ ▒ ▒░ ░ ░░   ░ ▒░ ░▒  ░ ░▒  ░ ░ ▒ ░▒░ ░
  ░░   ░    ░   ░        ░ ░ ░ ▒     ░   ░ ░  ░   ░  ░  ░   ░  ░░ ░
   ░        ░  ░░ ░          ░ ░           ░   ░        ░   ░  ░  ░
                ░                              ░                   '

    clear
    echo -e "${b_green}$banner${rs}\n"
    echo -e "${b_green}Author:${rs} ${b_yellow}catx0rr${rs}
${b_green}Github:${rs} ${b_yellow}https://github.com/catx0rr/Recon${rs}
"
}

function show_selection
{
    echo -e "${b_purple}[*]${rs} Please Select a Task to Execute:\n
[1] View Configuration
[2] Enumerate a Domain
[3] Pingsweep
[4] Portscan
[5] Nmap Scan (Requires sudo)
${b_green}[6]${rs} Help Screen
${b_red}[0]${rs} Exit
"

}

function show_help_screen
{
    show_banner
    echo -e " ${b_red}>> HELP SCREEN <<${rs}

${b_green}[+]${rs} Configuration Settings

${b_purple}[*]${rs} Target IP Address:
${b_green}[+]${rs} HELP: IP address to be used on port scanning.
          IP address to be used on nmap port scanning.
          IP address subnet is also used for ping sweeping.

${b_purple}[*]${rs} Target Ports:
${b_green}[+]${rs} HELP: Ports specified, start from 1 to set port will be scanned.

${b_purple}[*]${rs} Target Domain:
${b_green}[+]${rs} HELP: Targets the website domain, sweeps for subdomains and translates
          it to targetable IP addresses.

${b_purple}[*]${rs} Nmap Scan:
${b_green}[+]${rs} HELP: Perform a default scan that can be specified.
          IP Configuration will be targeted on the scanning.

${b_purple}[*]${rs} Output File:
${b_green}[+]${rs} HELP: All output file will be sent to ${b_yellow}$(pwd)/output${rs} directory.

"

    read -p ">> " getopt

    case $getopt in
        *)
            show_menu
            ;;
    esac
}

function show_menu 
{
	# Load new conf
	. $path/config/recon.conf
	
	# Validate configuration file
	validate_config	

	show_banner
	show_selection	

	read -p ">> " getopt

	case $getopt in
		1|[cC][oO][nN][fF][iI][gG])
			set_enum_config
			;;
		2|[eE][nN][uU][mM])
			start_enum_domain
			;;
		3|[pP][sS][wW])
			start_ping_sweep
			;;
		4|[pP][sS][cC])
			start_port_scan
			;;
		5|[nN][mM][aA][pP])
			start_nmap_scan
			;;
		6|[hH]|[hH][eE][lL][pP]) 
			show_help_screen
			;;
		0|[qQ]|[qQ][uU][iI][tT])	
			exit 0
			;;
		*)
			show_menu
			;;
	esac
}

function set_enum_config
{
	# Load new conf file
	. $path/config/recon.conf
    
	show_banner
    echo -e "${b_blue}[*]${rs} Your current configuration:

${b_blue}[>]${rs} Target IP Address: ${b_green}$HOST${rs}
${b_blue}[>]${rs} Target Ports: ${b_green}1-$PORT${rs}
${b_blue}[>]${rs} Target Domain: ${b_green}$DOMAIN${rs}
"
    read -p "Do you want to change your configuration? [y/N] >> " getopt

    case $getopt in
        [yY]|[yY][eE][sS])
            change_config
            ;;
        [nN]|[nN][oO])
            show_menu
            ;;
        *)
            set_enum_config
            ;;
    esac
}

function change_config
{
    show_banner
    echo -e "${b_purple}[*]${rs} Change what?:

[1] Target IP Address (current ${b_green}$HOST${rs})
[2] Target Ports (current ${b_green}1-$PORT${rs})
[3] Target Domain (current ${b_green}$DOMAIN${rs})
[4] Back to Main Menu
"
    read -p ">> " getopt

    case $getopt in
        1)
            ch_addr
            ;;
        2)
            ch_port
            ;;
        3)
            ch_domain
			;;

        4)
            show_menu
            ;;
        *)
            change_config
            ;;
    esac
}

function validate_config
{
	show_banner

	# validate the host configuration
	host_err

	# validate the end port configuration	
	port_err

	# validate the web domain configuration
	dom_err

	# validate for nmap
	nmap_err
}

