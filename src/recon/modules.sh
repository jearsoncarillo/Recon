#!/bin/bash

function start_enum_domain
{
	show_banner
	echo -e "${b_purple}[*]${rs} Starting enumeration for ${b_green}$DOMAIN${rs}..\n"
	echo -ne "${b_purple}[*]${rs} Enumerate ${b_green}$DOMAIN${rs}? [y/N] >> "
	read getopt

	case $getopt in
		[yY]|[yY][eE][sS])
			enumerate_domain
			;;
		[nN]|[nN][oO])
			show_menu
			;;
		*)
			start_enum_domain
			;;
	esac
}

function start_ping_sweep
{
	show_banner
	echo -e "${b_purple}[*]${rs} Starting ping sweep for ${b_green}$HOST.0${rs}..\n" | cut -d'.' -f1-3,5-7
	echo -ne "${b_purple}[*]${rs} Perform ping sweep? [y/N] >> "
	read getopt

	case $getopt in
		[yY]|[yY][eE][sS])
			ping_sweep
			;;
		[nN]|[nN][oO])
			show_menu
			;;
		*)
			start_ping_sweep
			;;
	esac
}

function start_port_scan
{
	show_banner
	echo -e "${b_purple}[*]${rs} Start port scan for ${b_green}$HOST${rs}..\n" 
	echo -ne "${b_purple}[*]${rs} Perform port scan? (${b_green}1-$PORT${rs})? [y/N] >> "
	read getopt

	case $getopt in
		[yY]|[yY][eE][sS])
			scanning_options
			;;
		[nN]|[nN][oO])
			show_menu
			;;
		*)
			start_port_scan
			;;

	esac
}

function start_nmap_scan
{
	show_banner
	echo -e "${b_purple}[*]${rs} Start nmap scan for ${b_green}$HOST${rs}..\n"
	echo -ne "${b_purple}[*]${rs} Perform port scan using nmap? [y/N] >> "
	read getopt

	case $getopt in
		[yY]|[yY][eE][sS])
			nmap_scan_options
			;;
		[nN]|[nN][oO])
			show_menu
			;;
		*)
			start_nmap_scan
			;;
	esac
}

function scanning_options
{
	echo -ne "${b_purple}[*]${rs} Show only open ports? [y/N] >> "
	read getopt

	case $getopt in
		[yY]|[yY][eE][sS])
			OPEN=1
			port_scan
			;;
		[nN]|[nN][oO])
			OPEN=0
			port_scan_warning
			;;
		*)
			scanning_options
			;;
	esac
}

function nmap_scan_options 
{
	echo -e "\n${b_purple}[*]${rs} NMAP Defaults:\n
${b_blue}[>]${rs} TCP Scan = ${b_green}$TCPSCAN${rs}
${b_blue}[>]${rs} Agressive Scan = ${b_green}$AGGRESSIVE${rs}
${b_blue}[>]${rs} Run Default Scripts = ${b_green}$DEFAULTSCRIPTS${rs}
${b_blue}[>]${rs} Perform OS Fingerprinting = ${b_green}$OSSCAN${rs}
${b_blue}[>]${rs} Perform Service Scan = ${b_green}$SERVICESCAN${rs}
${b_blue}[>]${rs} Timing = ${b_green}"$TIMING"${rs}
"
	echo -ne "${b_purple}[*]${rs} Read nmap options on the configuration file? [y/N] >> "
	read getopt
	echo

	case $getopt in
		[yY]|[yY][eE][sS])
			nmap_scan
			;;
		[nN]|[nN][oO])
			select_nmap_options
			;;
		*)
			nmap_scan_options
			;;
	esac
}

function save_to_file
{
	echo -ne "${b_purple}[*]${rs} Save to output file? [y/N] >> "
	read getopt

	case $getopt in
		[yY]|[yY][eE][sS])
			SAVE=1
			;;
		[nN]|[nN][oO])
			SAVE=0
			;;
		*)
			save_to_file
			;;

	esac
}

function enumerate_domain
{
	save_to_file

	if [[ $SAVE -eq 0 ]]; then
		enumerate_domain_nosave
	else
		enumerate_domain_save
	fi
}

function ping_sweep
{
	save_to_file

	if [[ $SAVE -eq 0 ]]; then
		ping_sweep_nosave
	else
		ping_sweep_save
	fi
}

function port_scan
{
	save_to_file

	if [[ $SAVE -eq 0 ]]; then
		port_scan_nosave
	else
		port_scan_save
	fi
}

function select_nmap_options
{
	function scantype {
		echo -ne "${b_purple}[*]${rs} TCP or UDP scan? [tcp/udp] >> "
		read getopt

		case $getopt in
			[tT][cC][pP])
				;;
			[uU][dD][pP])
				TCPSCAN=false
				;;
			*)
				scantype
				;;
		esac
	}

	function defaultscripts {
		echo -ne "${b_purple}[*]${rs} Run Default Scripts? [y/N] >> "
		read getopt

		case $getopt in
			""|[yY]|[yY][eE][sS])
				;;
			[nN]|[nN][oO])
				DEFAULTSCRIPTS=false
				;;
			*)
				select_nmap_options
				;;
		esac
	}
	
	function servicescan {
		echo -ne "${b_purple}[*]${rs} Perform Service Scan? [y/N] >> "
		read getopt

		case $getopt in
			""|[yY]|[yY][eE][sS])
				;;
			[nN]|[nN][oO])
				SERVICESCAN=false
				;;
			*)
				defaultscripts
				;;
		esac
	}

	function osscan {
		echo -ne "${b_purple}[*]${rs} Perform OS Fingerprinting? [y/N] >> "
		read getopt

		case $getopt in
			""|[yY]|[yY][eE][sS])
				;;
			[nN]|[nN][oO])
				OSSCAN=false
				;;
			*)
				osscan
				;;
		esac
	}

	function aggrescan {
		echo -ne "${b_purple}[*]${rs} Perform Aggresive Scan? [y/N] >> "
		read getopt

		case $getopt in
			""|[yY]|[yY][eE][sS])
				;;
			[nN]|[nN][oO])
				AGGRESSIVE=false
				;;
			*)
				aggrescan
				;;
		esac
	}
	
	function allports {
		echo -ne "${b_purple}[*]${rs} Scan all ports? (${b_green}1-65535${rs}) [y/N] >> "
		read getopt

		case $getopt in
			""|[yY]|[yY][eE][sS])
				ALLPORTS=true
				;;
			[nN]|[nN][oO])
				ALLPORTS=false
				;;
			*)
				allports
				;;
		esac
	}

	function timing {
		echo -ne "${b_purple}[*]${rs} Set scan timing: [${b_green}1-5${rs}] >> "
		read getopt

		case $getopt in
			1)
				TIMING=1
				;;
			2)
				TIMING=2
				;;
			3)
				TIMING=3
				;;
			4)
				TIMING=4
				;;
			5)
				TIMING=5
				;;
			*)
				timing
				;;
		esac
	}

	# Call nmap functions
	scantype
	defaultscripts
	servicescan
	osscan
	aggrescan
	allports
	timing	
	
	nmap_scan
}

function start_nikto_scan
{
    show_banner
    echo -e "${b_purple}[*]${rs} Start nikto scan for ${b_green}$HOST${rs}..\n"
    echo -ne "${b_purple}[*]${rs} Perform Web Vulnerability scan using nikto? [y/N] >> "
    read getopt

    case $getopt in
        [yY]|[yY][eE][sS])
            nikto_scan_options
            ;;
        [nN]|[nN][oO])
            show_menu
            ;;
        *)
            start_nikto_scan
            ;;
    esac
}

function nikto_scan_options
{
	function scantype {
        echo -ne "${b_purple}[*]${rs} Authenticated or not-authenticated scan? [auth/noauth] >> "
        read getopt

        case $getopt in
            [Aa][Uu][Tt][Hh])
                AUTH=true
                NOAUTH=false
                nikto_check_creds
                ;;
            [Nn][Oo][Aa][Uu][Tt][Hh])
                NOAUTH=true
                AUTH=false
                ;;
            *)
                scantype
                ;;
        esac
    }

    function nikto_check_creds {
        echo -ne "${b_purple}[*]${rs} Username: "
        read nikto_user

        if [[ $nikto_user =~ ^[A-Za-z0-9\._-]{3,32}$ ]]; then
            NIKTO_USER=$nikto_user
        else
            nikto_check_creds
        fi
        echo -ne "${b_purple}[*]${rs} "
        read -sp "Password (not echoed): " nikto_pass
        NIKTO_PASS=$nikto_pass
        echo
    }

    function format_output {
        echo -ne "${b_purple}[*]${rs} Choose a report format: [xml/csv/txt] >> "
        read getopt

        case $getopt in
            [Xx][Mm][Ll])
                NIKTO_XML=true
                NIKTO_CSV=false
                NIKTO_TXT=false
                ;;
            [Cc][Ss][Vv])
                NIKTO_CSV=true
                NIKTO_TXT=false
                NIKTO_XML=false
                ;;
            [Tt][Xx][Tt])
                NIKTO_TXT=true
                NIKTO_XML=false
                NIKTO_CSV=false
                ;;
            *)
                format_output
                ;;
        esac

    }

    function ssl_scan {
        echo -ne "${b_purple}[*]${rs} Scan host with SSL? [y/N] >> "
        read getopt

        case $getopt in
            [yY]|[Yy][Es][Ss])
                SSLSCAN=true
                ;;
            [Nn]|[Nn][Oo])
                SSLSCAN=false
                ;;
            *)
                ssl_scan
                ;;
        esac
    }

    function specify_ports {
        echo -ne "${b_purple}[*]${rs} Specify http(s) ports? [y/n] >> "
        read getopt

        case $getopt in
            [Yy]|[yY][eE][sS])
                enter_ports
                ;;
            [Nn]|[Nn][oO])
                NIKTO_PORTS='80,443'
                ;;
            *)
                specify_ports
                ;;
        esac
    }

    function enter_ports {
        echo -ne "${b_purple}[*]${rs} Target Ports (ex: ${b_green}80,443${rs}) >> "
        read getopt

        if [[ $getopt =~ ^([0-9]{1,5})+(,[0-9]{1,5})?+$ ]]; then
            NIKTO_PORTS=$getopt
        else
            enter_ports
        fi
    }

    # Call all required

    scantype
    specify_ports
    format_output
    ssl_scan

    nikto_scan
}
