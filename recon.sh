#!/bin/bash
#
#
#	╦═╗┌─┐┌─┐┌─┐┌┐┌ ┌─┐┬ ┬
#	╠╦╝├┤ │  │ ││││ └─┐├─┤
#	╩╚═└─┘└─┘└─┘┘└┘o└─┘┴ ┴
#
# | CyberDojo |
#
# Author: catx0rr 
# Github: https://github.com/catx0rr/Recon
#
# Disclaimer: 
#	This script is for educational purposes only. Use at your own discretion
#	I cannot be held responsilbe for any damages caused. Usage of these tools 
#	to attack sites, networks, domain is illegal without mutual consent.
#	I have no liability for any misuse. 
#
#	HELP:
#
#	type the following to move across menu.
#
#	config - View Configuration
#	enum - Enumerate a Domain
#	psw	- Start a ping sweep
#	psc - Start a port scan
# nmap - Use nmap scanner
#	help - Help Screen
#	exit - Quit recon.sh
#
#

path=`dirname $0`
. $path/config/recon.conf


function main
{
	show_menu
}

main
