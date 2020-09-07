#!/bin/sh

allSitesURL=""
allSitesCount=-1

terminalColors () {
	# Colors from - https://gist.github.com/5682077.git
	TC='\e['

	CLR_LINE_START="${TC}1K"
	CLR_LINE_END="${TC}K"
	CLR_LINE="${TC}2K"

	# Hope no terminal is greater than 1k columns
	RESET_LINE="${CLR_LINE}${TC}1000D"

	Bold="${TC}1m"    # Bold text only, keep colors
	Undr="${TC}4m"    # Underline text only, keep colors
	Inv="${TC}7m"     # Inverse: swap background and foreground colors
	Reg="${TC}22;24m" # Regular text only, keep colors
	RegF="${TC}39m"   # Regular foreground coloring
	RegB="${TC}49m"   # Regular background coloring
	Rst="${TC}0m"     # Reset all coloring and style

	# Basic            High Intensity      Background           High Intensity Background
	Black="${TC}30m";  IBlack="${TC}90m";  OnBlack="${TC}40m";  OnIBlack="${TC}100m";
	Red="${TC}31m";    IRed="${TC}91m";    OnRed="${TC}41m";    OnIRed="${TC}101m";
	Green="${TC}32m";  IGreen="${TC}92m";  OnGreen="${TC}42m";  OnIGreen="${TC}102m";
	Yellow="${TC}33m"; IYellow="${TC}93m"; OnYellow="${TC}43m"; OnIYellow="${TC}103m";
	Blue="${TC}34m";   IBlue="${TC}94m";   OnBlue="${TC}44m";   OnIBlue="${TC}104m";
	Purple="${TC}35m"; IPurple="${TC}95m"; OnPurple="${TC}45m"; OnIPurple="${TC}105m";
	Cyan="${TC}36m";   ICyan="${TC}96m";   OnCyan="${TC}46m";   OnICyan="${TC}106m";
	White="${TC}37m";  IWhite="${TC}97m";  OnWhite="${TC}47m";  OnIWhite="${TC}107m";
}

help () {
	echo "${Bold}Usage:${Rst}\neasy-apache [options]\n\n${Bold}Options:${Rst}\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
	echo "\n${Bold}Example\n${Rst}./easy-apache -f\t#for full installation i.e Apache & SSL certificate\n./easy-apache -a\t#for installating Apache server\n./easy-apache -s\t#for installating SSL certificate"
}

apacheInstall () {
	echo "${Bold}${Green}Installing Apache${Rst}"
	allSitesURL=""
	allSitesCount=-1

	echo "Updating Server"
	sudo apt update && sudo apt upgrade -y
	echo "Server updated"

	echo "Cleaning after upgrade"
	sudo apt autoremove -y && sudo apt autoclean -y

	IP=`curl -s icanhazip.com`
	echo "Server Public IP: ${Purple}"${IP}${Rst}

	#package search not working, disabled for now
	#dpkg -s apache2 &> /dev/null
	#if [ $? -eq 1 ]; then
		echo "Installing Apache 2"
		sudo apt install apache2 -y
		echo ${Purple}Apache `apache2 -v`"${Rst}"
	#fi

	while true
	do
		echo "${Green}===>${Rst} Setting up new site"
		read -p "URL (do not add www, eg input - helloworld.com): " siteURL

		if [ -e /etc/apache2/sites-available/$siteURL.conf ]
		then
			echo "${Red}$siteURL already exists, do you want to overwrite (Yy/Nn/99 to exit setup)?${Rst}"
			read overwriteSite
			case $overwriteSite in
				[Yy]* ) addSite $siteURL
						break;;
				[Nn]* ) continue;;
				[99]*  ) break;;
					* ) echo "${Red}Invalid input. Skipping $siteURL setup"
						continue;;
			esac
		else
			addSite $siteURL
			break
		fi
	done

	if [ $allSitesCount == -1 ]
	then
		echo "${Red}Exiting easy-apache. No Sites were added${Rst}"
		exit
	fi

	echo "Checking UFW"
	if sudo ufw status | grep -q inactive$
	then
		echo "${Red}UFW is disabled. You need to enable it to continue...${Rst}"
		
		while true
		do
			read -p "Do you want to enable now (Yy/Nn)? " ufwEnable
			case $ufwEnable in
				[Yy]* ) sudo ufw enable;
						echo "UFW enabled. Allowing SSH & Apache ports"
						sudo ufw allow ssh;
						sudo ufw allow Apache;
						break;;
				[Nn]* ) echo "${Red}You cannot view the site until you enable ufw and allow SSH & Apache${Rst}"; break;;
					* ) echo "Please answer yes(Yy) or no(Nn) ";;
			esac
		done
	else
		echo "UFW already enabled"
	fi

	echo "Disabling default site (/var/www/html)"
	sudo a2dissite 000-default.conf

	echo "Restarting Apache2 to activate new configuration"
	sudo systemctl restart apache2

	#TODO(pavank): try to check if site is available at server ${IP}

	echo "${Bold}${Green}Success! Your site(s) have been added successfully"
	echo "Point your domains A record to $IP and after DNS propagation everything should be working fine.${Rst}"
	echo "Sites added and configured are:"

	temp=-1
	while [ $temp != $allSitesCount ]
	do
		if [ -e /etc/apache2/sites-available/${allSitesURL[$temp]}-le-ssl.conf ]
		then
			temp=`expr $temp + 1`
			echo "https://${allSitesURL[$temp]}"
			continue
		fi
		temp=`expr $temp + 1`
		echo "http://"${allSitesURL[$temp]}
	done
}

addSite () {
	siteURL=$1
	#allSitesURL used for printing at last
	allSitesCount=`expr $allSitesCount + 1`
	allSitesURL[$allSitesCount]=$siteURL
	
	#used for directory name (which is without domain TLD, example.com site folder would be "example" not "example.com")
	siteNameNoTLD=`echo $siteURL | cut -d'.' -f1`

	sudo mkdir -p /var/www/$siteNameNoTLD
	sudo chown -R $USER:$USER /var/www/$siteNameNoTLD
	sudo chmod -R 755 /var/www

	#create temporary index.html page for viewing
	sudo echo "<h1>Server setup by <a href='https://github.com/realpvn/easy-apache.git'>easy-apache</a> (https://github.com/realpvn/easy-apache.git) </h1>" > /var/www/$siteNameNoTLD/index.html

	echo "Site $siteURL created, configuring"
	read -p "Email (leave blank if not required):" siteEmail
	if [ -z $siteEmail ]; then
		siteEmail=dev@localhost
	fi
	echo "<VirtualHost *:80>\n\tServerAdmin $siteEmail\n\tServerName $siteURL\n\tServerAlias www.$siteURL\n\tDocumentRoot /var/www/$siteNameNoTLD\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" | sudo tee /etc/apache2/sites-available/$siteURL.conf

	echo "Enabling site configuration"
	sudo a2ensite $siteURL.conf
}

sslInstall () {
	echo "${Bold}${Green}Installing SSL${Rst}"
	allSitesURL=""
	allSitesCount=-1

	dpkg -s certbot &> /dev/null
	if [ $? -eq 1 ]; then
		echo "Installing Certbot"
		sudo add-apt-repository ppa:certbot/certbot
		sudo apt install python-certbot-apache -y
	fi

	while true
	do
		echo "99 to exit"
		read -p "URL (do not add www, eg input - helloworld.com): " siteName

		if [ $siteName == 99 ]
		then
			echo "Good byee..."
			if [ $allSitesCount == -1 ]
			then
				exit
			fi
			break
		fi

		if [ ! -e /etc/apache2/sites-available/${siteName}.conf ]
		then
			echo "${siteName} does not exist.\n${Purple}Add it using './easy-apache -a'${Rst}"
			continue
		fi

		if [ -e /etc/apache2/sites-available/${siteName}-le-ssl.conf ]
		then
			echo "${Bold}${Green}${siteName} already has SSL installed${Rst}"
			continue
		fi

		allSitesCount=`expr $allSitesCount + 1`
		allSitesURL[$allSitesCount]=$siteName
		echo ${Purple}`expr $allSitesCount + 1`". "$siteName ${Rst}
		
		sudo certbot --apache -d www.$siteName -d $siteName
		if [ -e /etc/apache2/sites-available/$siteName-le-ssl.conf ]
		then
			echo "${Bold}${Green}SSL Successful for $siteName${Rst}"
			continue
		fi
		echo "${Bold}${Red}SSL unsuccessful for $siteName${Rst}, try again"
		exit
	done

	if [ $allSitesCount == -1 ]
	then
		echo "${Red}SSL Installation exiting because one of the following were true"
		echo "1. You had no sites added (try running 'easy-apache -a' to add site"
		echo "2. You already have ssl certificates installed"
		echo "Please check & run SSL Installation again${Rst}"
		exit
	fi

	echo "Allowing 'Apache Full' in ufw"
	sudo ufw delete allow 'Apache'
	sudo ufw allow 'Apache Full'

	echo "SSL added to sites:"
	temp=-1
	while [ $temp != $allSitesCount ]
	do
		if [ -e /etc/apache2/sites-available/${allSitesURL[$temp]}-le-ssl.conf ]
		then
			temp=`expr $temp + 1`
			echo "https://${allSitesURL[$temp]}"
			continue
		fi
		temp=`expr $temp + 1`
		echo "http://"${allSitesURL[$temp]}
	done
}

apacheSSLInstall () {
	apacheInstall
	echo "${Bold}${Green}Apache Installation complete${Rst}"
	echo "${Bold}${Green}Proceeding to SSL Installation${Rst}"
	sslInstall
}

terminalColors
while getopts 'fash' flag; do
	case ${flag} in
		f ) apacheSSLInstall; exit;;
		a ) apacheInstall; exit;;
		s ) sslInstall; exit;;
		h ) help; exit;;
		* ) help; exit;;
	esac
done
help