#!/bin/bash

##
# Steffen Senchyna 
# October 26 2021
# V1.1 Updated Archive function to specify folder and made logs more readable 
##


LOGFILESYS=$HOME/log/sysmonitor.txt
LOGFILENET=$HOME/log/netmonitor.txt
mkdir /tmp/backups/
LOGFILEARCHIVE=/tmp/backups/archivelog.txt
SERVERNAME=$(hostname)

#Memory check locally 
function memory_check() {
        echo ""
	echo "=============================="
	echo "Memory usage on ${SERVERNAME} is: "
	free -h
	echo "=============================="
	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS
	echo 'System Memory on local computer ${SERVERNAME}' >> $LOGFILESYS
	echo >> $LOGFILESYS
	free -h >> $LOGFILESYS		#Records to logfile
	echo "==============================" >> $LOGFILESYS
	echo >> $LOGFILESYS
	echo
	echo "Recorded to $LOGFILESYS"
}

#Check memory usage remotely using SSH 
function memory_check_remote() {
    echo ""
	read -p "Please enter the account name and IP address of the computer you wish monitor (username IP address): " USER IP
	echo "=============================="
	echo "Memory usage on $IP is: "
	ssh $USER@$IP free -h
	echo "=============================="
	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS
	echo System Memory on remote host $IP  >> $LOGFILESYS
	ssh $USER@$IP free -h >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	echo >> $LOGFILESYS
	echo 
	echo "Recorded to $LOGFILESYS"
}

#CPU usage locally 
function cpu_check() {
    	echo ""
	echo "=============================="
	echo "CPU load on ${SERVERNAME} is: "
    	echo ""
	uptime
	echo "=============================="
	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS		#Records to logfile 
	echo 'CPU Usage on local host ${SERVERNAME}' >> $LOGFILESYS
	uptime >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS		
	echo >> $LOGFILESYS
	echo
	echo "Recorded to $LOGFILESYS"
}

#Checks CPU usage remotely using SSH
function cpu_check_remote() {
    echo ""
	read -p "Please enter the account name and IP address of the computer you wish monitor (username IP address): " USER IP
	echo "=============================="
	echo "CPU usage on $IP is: "
	ssh $USER@$IP uptime
	echo "=============================="
	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS
	echo "CPU Usage on remote host $IP"  >> $LOGFILESYS
	ssh $USER@$IP uptime >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS		
	echo >> $LOGFILESYS
	echo ""
	echo "Recorded to $LOGFILESYS"
}

#TCP Check 
function tcp_check() {
    	echo ""
	echo "=============================="
	echo "TCP connections on ${SERVERNAME}: "
	cat  /proc/net/tcp | wc -l
	echo "=============================="
    	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS		
	echo 'TCP Connections on local host ${SERVERNAME}' >> $LOGFILESYS
	uptime >> $LOGFILESYS	
	echo "==============================" >> $LOGFILESYS			
	echo >> $LOGFILESYS
	echo "Recorded to $LOGFILESYS"
}

#TCP Check remotely using SSH 
function tcp_check_remote() {
    echo ""
	read -p "Please enter the account name and IP address of the computer you wish monitor (username IP address): " USER IP
	echo "=============================="
	echo "TCP connections on $IP is: "
	ssh $USER@$IP cat  /proc/net/tcp | wc -l
	echo "=============================="
	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS
	echo "TCP connections on remote host $IP"  >> $LOGFILESYS
	ssh $USER@$IP uptime >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	echo >> $LOGFILESYS
	echo ""
	echo "Recorded to $LOGFILESYS"
}

#Local Disk Check 
function disk_check() {
    	echo ""
	echo "=============================="
	echo "Disk space available on local host ${SERVERNAME} is: "
	df -h
	echo "=============================="
    	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS
	echo 'Data Block Usage on local host ${SERVERNAME}' >> $LOGFILESYS
	df -h >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	echo >> $LOGFILESYS
	echo "Recorded to $LOGFILESYS"	
}

#Remote Disk Check using SSH
function disk_check_remote() {
    echo ""
	read -p "Please enter the account name and IP address of the computer you wish monitor (username IP address): " USER IP
	echo 
	echo "=============================="
	echo "Disk space on $IP is: "
	ssh $USER@$IP df -h
	echo "=============================="
	echo ""
	echo >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	date >> $LOGFILESYS
	echo "Disk space on remote host $IP"  >> $LOGFILESYS
	ssh $USER@$IP df -h >> $LOGFILESYS
	echo "==============================" >> $LOGFILESYS
	echo >> $LOGFILESYS
	echo ""
	echo "Recorded to $LOGFILESYS"
}
#Runs all functions 
function all_checks() {
	memory_check
	cpu_check
	tcp_check
	disk_check
}
#Runs all remote functions 
function all_checks_remote() {
	memory_check_remote
	cpu_check_remote
	tcp_check_remote
	disk_check_remote
}
	
#Immediate Back Up
function back_up() {
	read -p "Please enter the file directory you wish to back up: " DIR	#V1.1 Updated to specify the directory of backup 
	sudo rsync -avzhr $DIR /tmp/backups
	echo "" >> $LOGFILEARCHIVE
	echo "==============================" >> $LOGFILEARCHIVE				#V1.1 Updated to make nicer looking log file 
	echo "Latest backup for $DIR" >> $LOGFILEARCHIVE  
	date >>$LOGFILEARCHIVE
	echo "==============================" >> $LOGFILEARCHIVE
	echo "" >> $LOGFILEARCHIVE
	echo "=============================="
	echo Backed up to /tmp/backups
	echo Logged in $LOGFILEARCHIVE
	echo "=============================="
}

#Edits crontab to get reccuring backups 
function back_up_time() {
	read -p "Please enter the file directory you wish to back up: " DIR
	read -p "Please input the recurring schedule in the format, put * in unwanted spaces [min(0-59) hour(0-23) day(1-31) month(1-12) weekday(0-6)]: " MIN HOUR DAY MONTH WEEKDAY
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY rsync -avzhr $DIR /tmp/backups") | crontab -  
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY echo "" >> $LOGFILEARCHIVE ") | crontab - 
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY echo '==============================' >> $LOGFILEARCHIVE ") | crontab - 
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY echo 'Latest backup for $DIR' >> $LOGFILEARCHIVE ") | crontab - 
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY date >> $LOGFILEARCHIVE") | crontab - 
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY echo '==============================' >> $LOGFILEARCHIVE ") | crontab - 
	(crontab -l && echo "$MIN $HOUR $DAY $MONTH $WEEKDAY echo "" >> $LOGFILEARCHIVE") | crontab - 
	crontab -l
}
#This clears the crontab 
function back_up_clear() {
	echo "" | crontab -
	crontab -l
}

function network_uptime() {
	read -p "Input a IP on a subnet to ping to test a network card: " IP
	while ping -w 1 -c 1 $IP ;  #Pings until timeout
	do sleep 1 ; 
	done ; 
	echo "Server $IP stopped responding at $(date)" 
	echo "" >> $LOGFILENET
	echo "==============================" >> $LOGFILENET					#V1.1 Updated to make nicer looking log file 
	echo "Server $IP stopped responding at $(date)" >> $LOGFILENET
	echo "==============================" >> $LOGFILENET
	echo "" >> $LOGFILENET
	
}


#Archive Menu 
menu_archive(){
echo -ne "
Backup Menu
$(ColorGreen '1)') Immediate
$(ColorGreen '2)') Reccuring
$(ColorGreen '3)') Clear Crontab Schedule  
$(ColorGreen '0)') Go Back
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) back_up ; menu_archive ;;
	        2) back_up_time ; menu_archive ;;
	        3) back_up_clear ; menu_archive ;;
		0) menu ; menu ;;
		*) echo -e $red"Wrong Option."$clear; WrongCommand;;
        esac
}


#Local Host Monitor Menu
local_menu(){
echo -ne "
Local Menu
$(ColorGreen '1)') Memory usage
$(ColorGreen '2)') CPU load
$(ColorGreen '3)') Number of TCP connections 
$(ColorGreen '4)') Disk Space
$(ColorGreen '5)') Check All
$(ColorGreen '0)') Go Back
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) memory_check ; local_menu ;;
	        2) cpu_check ; local_menu ;;
	        3) tcp_check ; local_menu ;;
	        4) disk_check ; local_menu ;;
	        5) all_checks ; local_menu ;;
		0) menu ; menu ;;
		*) echo -e $red"Wrong Option."$clear; WrongCommand;;
        esac
}
#Remote Host Monitor Menu
remote_menu(){
echo -ne "
Remote Menu
$(ColorGreen '1)') Memory usage
$(ColorGreen '2)') CPU load
$(ColorGreen '3)') Number of TCP connections 
$(ColorGreen '4)') Disk Space
$(ColorGreen '5)') Check All
$(ColorGreen '0)') Go Back
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) memory_check_remote ; remote_menu ;;
	        2) cpu_check_remote ; remote_menu ;;
	        3) tcp_check_remote ; remote_menu ;;
	        4) disk_check_remote ; remote_menu ;;
	        5) all_checks_remote ; remote_menu ;;
		0) menu ; menu ;;
		*) echo -e $red"Wrong Option."$clear; WrongCommand;;
        esac
}
#Host Monitor Menu 
menuhostmonitor(){
echo -ne "
Host Monitor Menu
$(ColorGreen '1)') Local
$(ColorGreen '2)') Remote
$(ColorGreen '0)') Go Back
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) local_menu ; menu ;;
	        2) remote_menu ; menu ;;
		0) menu ; menu;;
		*) echo -e $red"Wrong Option."$clear; WrongCommand;;
        esac
}
#Log View Menu
logmenu(){
echo -ne "
Log Menu Menu
$(ColorGreen '1)') Archive Log
$(ColorGreen '2)') System Monitor Log 
$(ColorGreen '3)') Network Monitor Log 
$(ColorGreen '0)') Go Back
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) cat $LOGFILEARCHIVE ; logmenu ;;
	        2) cat $LOGFILESYS ; logmenu ;;
		3) cat $LOGFILENET ; logmenu ;;
		0) menu ; menu;;
		*) echo -e $red"Wrong Option."$clear; WrongCommand;;
        esac
}
	
##
# Color  Variables
##
red='\033[31m'
green='\e[32m'
blue='\e[34m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

#Main Menu 
menu(){
echo -ne "
Menu
$(ColorGreen '1)') Host Monitor
$(ColorGreen '2)') Back Up
$(ColorGreen '3)') Network Uptime 
$(ColorGreen '4)') View Logs
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) menuhostmonitor ; menu ;;
	        2) menu_archive ; menu ;;
		3) network_uptime ; menu ;;  
		4) logmenu ; menu ;;
		0) exit 0 ;;
		*) echo -e $red"Wrong Option."$clear; WrongCommand;;
        esac
}

# Call the menu function
menu
