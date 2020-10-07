#!/bin/bash

function ch_addr
{
	show_banner
	
	echo -e "${b_green}[+]${rs} Changing IP Address..\n"
	echo -ne "${b_purple}[*]${rs} Enter New IP address: >> "
	read getopt

	# Validate and change the last occurence of HOST IP from the config file
	if [[ $getopt =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		tac $path/config/recon.conf | sed "0,/HOST='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'/s//HOST=\'$getopt\'/" \
		| tac | tee $path/config/recon.conf
		clear
		set_enum_config
		
	else
		echo -e "\n${b_red}[-]${rs} Incorrect IP Address Format."
		sleep 0.75
		ch_addr
	fi
}

function ch_port
{
	show_banner
	
	echo -e "${b_green}[+]${rs} Changing Port..\n"
	echo -ne "${b_purple}[*]${rs} Enter a desired end port: (${b_green}2-65535${rs}) >> "
	read getopt

	# Validate and change the last occurence of PORT from the config file
	if [[ $getopt =~ ^[0-9]{1,5}$ ]]; then
		tac $path/config/recon.conf | sed "0,/PORT=[0-9]\{1,5\}/s//PORT=$getopt/" \
		| tac | tee $path/config/recon.conf
		clear
		set_enum_config
	else
		echo -e "\n${b_red}[-]${rs} Incorrect Port Number specified."
		sleep 0.75
		ch_port
	fi
}

function ch_domain
{
	show_banner
	
	echo -e "${b_green}[+]${rs} Changing Website Domain..\n"
	echo -ne "${b_purple}[*]${rs} Enter a desired domain name: (i.e ${b_green}cisco.com${rs}) >> "
	read getopt

	# Validate and change the last occurence of the domain from the config file
	if [[ $getopt =~ ^([A-Za-z0-9_-])+(\.[A-Za-z]{2,5})+(\.[A-Za-z]{2,5})?$ ]]; then
		tac $path/config/recon.conf | sed -r "0,/DOMAIN='([A-Za-z0-9_-])+(\.[A-Za-z]{2,5})+(\.[A-Za-z]{2,5})?'/s//DOMAIN=\'$getopt\'/" \
		| tac | tee $path/config/recon.conf
		clear
		set_enum_config
	else
		echo -e "\n${b_red}[-]${rs} Incorrect Domain specified."
		sleep 0.75
		ch_domain
	fi
}

function host_err
{
	# Check if configuration file has valid hosts.
	HOSTERR=$(grep -oi '^host=\(\.*\).*' $path/config/recon.conf | wc -l)

    if [[ $HOSTERR -eq 0 ]]; then
        echo -e "${b_red}[-]${rs} ERROR: No hosts detected on the configuration file.
"
		read -p ">> " getopt

		case $getopt in
			*)
				exit 0
				;;
		esac
	
	elif [[ $HOSTERR -ge 2 ]]; then
		echo -e "${b_red}[-]${rs} ERROR: Two or more hosts detected on the configuration file.
"	
		read -p ">> " getopt

		case $getopt in
			*)
				exit 0
				;;
		esac
	fi
}

function port_err
{
	# Check if configuration file has valid ports.
	PORTERR=$(grep -oi '^port=\(\.*\).*' $path/config/recon.conf | wc -l)
	
	if [[ $PORTERR -eq 0 ]]; then
		echo -e "${b_red}[-]${rs} ERROR: No end ports detected on the configuration file.
"
		read -p ">> " getopt
	
		case $getopt in
			*)
				exit 0
				;;
		esac

	elif [[ $PORTERR -ge 2 ]]; then
		echo -e "${b_red}[-]${rs} ERROR: Two or more end ports detected on the configuration file.
"
		read -p ">> " getopt

		case $getopt in
			*)
				exit 0
				;;
		esac
	fi
}

function dom_err
{
	# Check if the configuration file has valid domains.
	DOMERR=$(grep -oi '^domain=\(\.*\).*' $path/config/recon.conf | wc -l)

	if [[ $DOMERR -eq 0 ]]; then
		echo -e "${b_red}[-]${rs} ERROR: No web domain detected on the configuration file.
"
		read -p ">> " getopt

		case $getopt in
			*)
				exit 0
				;;
		esac

	elif [[ $DOMERR -ge 2 ]]; then
		echo -e "${b_red}[-]${rs} ERROR: Two or more web domains detected on the configuration file.
"
		read -p ">> " getopt
		
		case $getopt in
			*)
				exit 0
				;;
		esac
	fi
}

function nmap_err
{
  function check_nmap
  {
    read -p ">> " getopt

    case $getopt in
      *)
		echo -ne "\n${b_purple}[*]${rs} Install nmap? [y/N] >> "
		read getopt

        case $getopt in
          ""|[yY]|[yY][eE][sS])
              echo -e "${b_green}[+]${rs} Installing nmap..\n"
              sudo apt-get install -y nmap > /dev/null
              

              echo -ne "${b_green}[+]${rs} Nmap is now installed. >> "
	      read getopt

			  case $getopt in
                  *)
                    show_menu
                    ;;
              esac
              ;;
          *)
              exit 1
              ;;
      esac
    esac
  }

  # Check if nmap is installed
  if ! command -v nmap &> /dev/null; then
    echo -e "${b_red}[-]${rs} No nmap installed on your machine..\n"
    check_nmap
  fi
}

function enumerate_domain_nosave 
{
	# Download index of target domain
	sleep .25
	echo -e "\n${b_green}[+]${rs} Downloading index.."
	mkdir -p $path/output/$DOMAIN 2>/dev/null
	wget $DOMAIN -O $path/output/$DOMAIN/$DOMAIN.html -q
	sleep .75

	# Get the subdomains captured
	sleep .25
	echo -e "${b_green}[+]${rs} Scraping for subdomains.."
	grep -o '[A-Za-z0-9_\.-]'*$DOMAIN $path/output/$DOMAIN/$DOMAIN.html \
	| sort -u >> $path/output/$DOMAIN/subdomains.$DOMAIN.out
	sleep .75

	# Translate scraped subdomains to IPs
	sleep .25
	echo -e "${b_green}[+]${rs} Capturing IP addresses..\n"
	sleep .75
	for i in $(cat $path/output/$DOMAIN/subdomains.$DOMAIN.out); do host $i; done \
	| grep "has address" | awk '{print $4}' | sort -u

	# Cleaning output directory
	rm -rf $path/output/$DOMAIN

	echo -e "\n${b_green}[+]${rs} Done. 
	"

	read -p ">> " getopt

	case $getopt in
		*)
			clear
			show_menu
			;;
	esac
}

function enumerate_domain_save
{
	# Download index of target domain
	sleep .25
	echo -e "\n${b_green}[+]${rs} Downloading index.."
	mkdir -p $path/output/$DOMAIN 2>/dev/null
	wget $DOMAIN -O $path/output/$DOMAIN/$DOMAIN.html -q
	sleep .75

	# Get the subdomains captured
	sleep .25
	echo -e "${b_green}[+]${rs} Scraping for subdomains.."
	grep -o '[A-Za-z0-9_\.-]'*$DOMAIN $path/output/$DOMAIN/$DOMAIN.html \
	| sort -u >> $path/output/$DOMAIN/subdomains.$DOMAIN.out
	sleep .75

	# Translate scraped subdomains to IPs
	sleep .25
	echo -e "${b_green}[+]${rs} Capturing IP addresses..\n"
	sleep .75
	for i in $(cat $path/output/$DOMAIN/subdomains.$DOMAIN.out); do host $i; done \
	| grep "has address" | awk '{print $4}' | sort -u | tee -a $path/output/$DOMAIN/ip.$DOMAIN.out

	echo -e "\n${b_green}[+]${rs} Done. Data saved on ${b_yellow}$(find "$(pwd)"/ -type f -name ip.$DOMAIN.out)${rs}
	"

	read -p ">> " getopt

	case $getopt in
		*)
			clear
			show_menu
			;;
	esac
}

function ping_sweep_nosave
{
    SUBNET=$(echo $HOST | cut -d'.' -f1-3)

    sleep .25
    echo -e "${b_green}[+]${rs} Sweeping the subnet for live hosts..\n"
    sleep .75

    for i in {1..254}; do ping -c1 $SUBNET.$i | tr \\n ' ' | awk '/1 received/ {print Host $2 is up}' & done

	sleep 2
    echo -e "\n${b_green}[+]${rs} Done.
    "

    read -p ">> " getopt

    case $getopt in
        *)
            clear
            show_menu
            ;;
    esac
}

function ping_sweep_save
{
	mkdir -p $path/output/pingsweep
    SUBNET=$(echo $HOST | cut -d'.' -f1-3)

    sleep .25
    echo -e "${b_green}[+]${rs} Sweeping the subnet for live hosts..\n"
    sleep .75
    echo -e "Live Hosts on $SUBNET.0:\n" >> $path/output/pingsweep/subnet.$SUBNET.0.out

    for i in {1..254}; do ping -c1 $SUBNET.$i | tr \\n ' ' | awk '/1 received/ {print Host $2 is up}' & done \
    | tee -a $path/output/pingsweep/subnet.$SUBNET.0.out

    echo -e "\n${b_green}[+]${rs} Done. Data saved on ${b_yellow}$(find "$(pwd)"/ -type f -name subnet.$SUBNET.0.out)${rs}
    "

    read -p ">> " getopt

    case $getopt in
        *)
            clear
            show_menu
            ;;
    esac
}

function port_scan_nosave
{
    sleep .25
    echo -e "${b_green}[+]${rs} Scanning for Open Ports..\n"
    sleep .75

    # Check for scanning opts

    if [[ $OPEN -eq 1 ]]; then
        for i in `seq 1 $PORT`; do (echo > /dev/tcp/$HOST/"$i") > /dev/null \
        2>&1 && echo "Port is open: $i"; done
    else
		for i in `seq 1 $PORT`; do (echo > /dev/tcp/$HOST/"$i") > /dev/null \
        2>&1 && echo "Port is open: $i" || echo "Port is closed: $i"; done
    fi

    echo -e "\n${b_green}[+]${rs} Done.
    "

	read -p ">> " getopt
	
	case $getopt in
		*)
			show_menu
			;;
	esac

}

function port_scan_save
{
	mkdir -p $path/output/portscan

    sleep .25
    echo -e "${b_green}[+]${rs} Scanning for Open Ports..\n"
    sleep .75

    # Check for scanning opts

    if [[ $OPEN -eq 1 ]]; then

        echo -e "Open Ports on host $HOST:\n" >> $path/output/portscan/port-open.$HOST.out

        for i in `seq 1 $PORT`; do (echo > /dev/tcp/$HOST/"$i") > /dev/null \
        2>&1 && echo "Port is open: $i"; done \
        | tee -a $path/output/portscan/port-open.$HOST.out

        echo -e "\n${b_green}[+]${rs} Done. Data saved on ${b_yellow}$(find "$(pwd)"/ -type f -name "port-open.$HOST.out")${rs}
        "
    else
		    for i in `seq 1 $PORT`; do (echo > /dev/tcp/$HOST/"$i") > /dev/null \
        2>&1 && echo "Port is open: $i" || echo "Port is closed: $i"; done \
        | tee -a $path/output/portscan/port-open-closed.$HOST.out
		  
        echo -e "\n${b_green}[+]${rs} Done. Data saved on ${b_yellow}$(find "$(pwd)"/ -type f -name "port-open-closed.$HOST.out")${rs}
        "
    fi

	read -p ">> " getopt

	case $getopt in
		*)  
			show_menu
			;;
	esac
}

function port_scan_warning
{
  echo -ne "${b_yellow}[!]${rs} Showing port state may generate huge pile of text. Proceed? [y/N] >> "
  read getopt

        case $getopt in
            [yY]|[yY][eE][sS])
				port_scan
                ;;  
            [nN]|[nN][oO])
                start_port_scan
                ;;  
            *)
                port_scan_warning
                ;;  
        esac
}

function nmap_scan
{
        save_to_file

        echo -e "\n${b_green}[+]${rs} Executing Nmap.. Scanning Ports..\n"

        if [[ $TCPSCAN == 'false' ]]; then
                TCPSCAN='-sU'
        else
                TCPSCAN=''
        fi

        if [[ $DEFAULTSCRIPTS == 'true' ]]; then
                DEFAULTSCRIPTS='-sC'
        else
                DEFAULTSCRIPTS=''
        fi

        if [[ $SERVICESCAN == 'true' ]]; then
                SERVICESCAN='-sV'
        else
                SERVICESCAN=''
        fi

        if [[ $OSSCAN == 'true' ]]; then
                OSSCAN='-O'
        else
                OSSCAN=''
        fi

        if [[ $AGGRESSIVE == 'true' ]]; then
                AGGRESSIVE='-A'
        else
                AGGRESSIVE=''
        fi

        if [[ $ALLPORTS == 'true' ]]; then
                ALLPORTS='-p-'
        else
                ALLPORTS=''
        fi

        # Perform nmap scan

        if [[ $SAVE -eq 0 ]]; then
                sudo nmap $TCPSCAN $SERVICESCAN $DEFAULTSCRIPTS $AGGRESSIVE \
                $OSSCAN -T$TIMING $HOST $ALLPORTS -v

                echo -e "\n${b_green}[+]${rs} Done.\n"
                read -p ">> " getopt

                case $getopt in
                    *)
                        show_menu
                        ;;
                esac
        else
                mkdir -p $path/output/nmap/nmap-$HOST

                sudo nmap $TCPSCAN $SERVICESCAN $DEFAULTSCRIPTS $AGGRESSIVE \
                $OSSCAN -T$TIMING $HOST $ALLPORTS -v -oA $path/output/nmap/nmap-$HOST/$HOST

                echo -e "\n${b_green}[+]${rs} Done. Data saved on ${b_yellow}$(find "$(pwd)"/ -type d -name nmap-$HOST)\n${rs}"
                
                read -p ">> " getopt

                case $getopt in
					*)
						show_menu
						;;
                esac
        fi
}

function nikto_scan
{
    echo -e "\n${b_green}[+]${rs} Executing Nikto Scan.. Scanning Vulnerabilities..\n"

    if [[ $AUTH == 'true' ]]; then
        AUTH='-id $NIKTO_USER:$NIKTO_PASS'
    else
        AUTH=''
    fi


    if [[ $NIKTO_XML == 'true' ]]; then
        mkdir -p $path/output/nikto/nikto-$HOST
        NIKTO_OUTPUT="-Format xml -o `echo $path`/output/nikto/nikto-$HOST/VA-SCAN-$HOST.xml"
    fi

    if [[ $NIKTO_CSV == 'true' ]]; then
        mkdir -p $path/output/nikto/nikto-$HOST
        NIKTO_OUTPUT="-Format csv -o `echo $path`/output/nikto/nikto-$HOST/VA-SCAN-$HOST.csv"
    fi

    if [[ $NIKTO_TXT == 'true' ]]; then
        mkdir -p $path/output/nikto/nikto-$HOST
        NIKTO_OUTPUT="-Format txt -o `echo $path`/output/nikto/nikto-$HOST/VA-SCAN-$HOST.txt"
    fi

    if [[ $SSLSCAN = 'true' ]]; then
        SSLSCAN='-ssl'
    fi 

    sudo nikto -h $HOST $AUTH $NIKTO_OUTPUT $SSLSCAN

    echo -e "\n${b_green}[+]${rs} Done. Scan output saved on ${b_yellow}$(find "$(pwd)"/ -type d -name nikto-$HOST)\n${rs}"

    read -p ">> " getopt

    case $getopt in
        *)
            show_menu
            ;;
    esac
}
