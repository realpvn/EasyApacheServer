cat easy-banner.txt
serverIP=`curl -s icanhazip.com`

terminalColors () {
	# Colors from - https://gist.github.com/5682077.git
	TC='\e['

	Bold="${TC}1m"    # Bold text only, keep colors
	Undr="${TC}4m"    # Underline text only, keep colors
	Rst="${TC}0m"     # Reset all coloring and style

	# Basic colors
	Black="${TC}30m"
	Red="${TC}31m"
	Green="${TC}32m"
	Yellow="${TC}33m"
	Blue="${TC}34m"
	Purple="${TC}35m"
	Cyan="${TC}36m"
	White="${TC}37m"

	Crossed="\u2718"

	#copy pasted tick symbold because unicode was acting weird
	Ticked="✓"
	Info="!"

	Oper=${Bold}'[ * ]'
	OperSuccess=${Bold}${Green}'[ '${Ticked}' ]'
	OperFailed=${Bold}${Red}'[ '${Crossed}' ]'
	Info=${Bold}${Yellow}'[ '${Info}' ]'
}

printNormal () {
	echo -e "${Oper} $1$Rst";
}

printSuccess() {
	echo -e "${OperSuccess} $1$Rst"
}

printFailed() {
	echo -e "${OperFailed} $1$Rst"
}

printInfo() {
	echo -e "${Info} $1$Rst"
}

help () {
	echo -e "${Bold}Usage:${Rst}\neasy-apache [options]\n\n${Bold}Options:${Rst}\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
	echo -e "\n${Bold}Example\n${Rst}easy-apache -f\t#for full installation i.e Apache & SSL certificate\neasy-apache -a\t#for installating Apache server\neasy-apache -s\t#for installating SSL certificate"
}

apacheInstall () {
	printInfo "Server Public IP: ${Yellow}${Bold}"${serverIP}${Rst}

	printNormal "Updating Server, might take few mins"
	sudo apt update -y &> /dev/null
	printNormal "Almost done"
	sudo apt upgrade -y &> /dev/null
	printSuccess "Updated"

	sudo apt autoremove -y &> /dev/null
	sudo apt autoclean -y &> /dev/null
	printSuccess "Cleaned after server update"

	allSitesURL=""
	allSitesCount=-1

	dpkg -s apache2 &> /dev/null
	if [ $? -eq 1 ]; then
		sudo apt install apache2 -y &> /dev/null
		printSuccess "Apache Installed"
		printInfo "${Yellow}${Bold}Apache `apache2 -v`${Rst}"
	else
		printSuccess "Apache already Installed"
	fi

	while true
	do
		printInfo "Setting up new site"
		read -p "Site URL (99 - exit): " siteURL

		if [[ -z "$siteURL" ]]
		then
			printFailed "Site URL empty"
			break
		fi

		if [ $siteURL == 99 ]
		then
			if [ $allSitesCount == -1 ]
			then
				echo "Good byee..."
				exit
			fi
			break
		fi

		re="(https:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)"
		if [[ ! $siteURL =~ $re ]]
		then
			printFailed "Invalid URL"
			continue
		fi

		printSuccess "URL Valid"

		if [ -e /etc/apache2/sites-available/$siteURL.conf ]
		then
			printFailed "$siteURL already exists"
			printInfo "Do you want to overwrite $siteURL? (Yy/Nn/99 to exit setup)"
			read overwriteSite
			case $overwriteSite in
				[Yy]* ) #allSitesURL used for printing at last
						allSitesCount=`expr $allSitesCount + 1`
						allSitesURL[$allSitesCount]=$siteURL
						addSite $siteURL
						break;;
				[Nn]* ) continue;;
				[99]* ) break;;
					* ) printInfo "Invalid input. Skipping $siteURL setup"
						continue;;
			esac
		else
			#allSitesURL used for printing at last
			allSitesCount=`expr $allSitesCount + 1`
			allSitesURL[$allSitesCount]=$siteURL
			addSite $siteURL
			break
		fi
	done

	if [ $allSitesCount == -1 ]
	then
		exit
	fi

	if sudo ufw status | grep -q inactive$
	then
		printInfo "UFW is disabled. You need to enable it to continue..."
		
		while true
		do
			read -p "Do you want to enable now (Yy/Nn)? " ufwEnable
			case $ufwEnable in
				[Yy]* ) echo "y" | sudo ufw enable &> /dev/null;
						printSuccess "UFW enabled"
						sudo ufw allow ssh &> /dev/null;
						sudo ufw allow Apache &> /dev/null;
						printSuccess "Allowed SSH & Apache in ufw"
						break;;
				[Nn]* ) printInfo "You cannot view the site until you enable ufw and allow SSH & Apache"; break;;
					* ) echo -e "Please answer yes(Yy) or no(Nn) ";;
			esac
		done
	else
		printSuccess "UFW already enabled"
	fi

	sudo a2dissite 000-default.conf &> /dev/null
	printSuccess "Disabled default site"

	sudo systemctl restart apache2
	printSuccess "Apache restart success"

	#TODO(pavank): try to check if site is available at server ${IP}

	printSuccess "Success! Your site(s) have been added successfully"
	printSuccess "Point your domains A record to $IP and after DNS propagation everything should be working fine.${Rst}"
	echo -e "Sites added and configured are:"

	temp=-1
	while [ $temp != $allSitesCount ]
	do
		if [ -e /etc/apache2/sites-available/${allSitesURL[$temp]}-le-ssl.conf ]
		then
			temp=`expr $temp + 1`
			echo -e "https://${allSitesURL[$temp]}"
			continue
		fi
		temp=`expr $temp + 1`
		echo -e "http://"${allSitesURL[$temp]}
	done
}

addSite () {
	siteURL=$1

	#used for directory name (which is without domain TLD, example.com site folder would be "example" not "example.com")
	siteNameNoTLD=`echo -e $siteURL | cut -d'.' -f1`

	printInfo "Creating directory & adding permissions"
	sudo mkdir -p /var/www/$siteNameNoTLD
	sudo chown -R $USER:$USER /var/www/$siteNameNoTLD
	sudo chmod -R 755 /var/www
	printSuccess "Done"

	#create temporary index.html page for viewing
	sudo echo -e "<h1>Server setup by <a href='https://github.com/realpvn/easy-apache.git'>easy-apache</a> (https://github.com/realpvn/easy-apache.git) </h1>" &> /var/www/$siteNameNoTLD/index.html

	printSuccess "Site $siteURL created"
	printNormal "Configuring"
	read -p "Email (leave blank if not required):" siteEmail
	if [ -z $siteEmail ]; then
		siteEmail=dev@localhost
	fi
	echo -e "<VirtualHost *:80>\n\tServerAdmin $siteEmail\n\tServerName $siteURL\n\tServerAlias www.$siteURL\n\tDocumentRoot /var/www/$siteNameNoTLD\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" | sudo tee /etc/apache2/sites-available/$siteURL.conf
	printSuccess "Site $siteURL configured successfully"

	sudo a2ensite $siteURL.conf &> /dev/null
	printSuccess "Enabled configuration for $siteURL"
}

sslInstall () {
	printNormal "SSL Installation"
	allSitesURL=""
	allSitesCount=-1

	dpkg -s certbot &> /dev/null
	if [ $? -eq 1 ]; then
		sudo apt install certbot python3-certbot-apache -y &> /dev/null
		printSuccess "Installed Certbot"
	fi

	while true
	do
		read -p "Site URL to add SSL (99 - Exit): " siteName
		if [[ -z "$siteName" ]]
		then
			printFailed "Site URL empty"
			break
		fi

		if [ $siteName == 99 ]
		then
			if [ $allSitesCount == -1 ]
			then
				echo -e "Good byee..."
				exit
			fi
			break
		fi

		re="(https:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)"
		if [[ ! $siteName =~ $re ]]
		then
			printFailed "Invalid URL"
			printInfo "Example site URL - example.com"
			continue
		fi

		if [ ! -e /etc/apache2/sites-available/${siteName}.conf ]
		then
			printFailed "${siteName} does not exist"
			printInfo "Use 'easy-apache -a' to add a site"
			exit
		fi

		if [ -e /etc/apache2/sites-available/${siteName}-le-ssl.conf ]
		then
			printFailed "${siteName} already has SSL installed"
			continue
		fi

		allSitesCount=`expr $allSitesCount + 1`
		allSitesURL[$allSitesCount]=$siteName
		
		sudo certbot --apache -d www.$siteName -d $siteName
		if [ -e /etc/apache2/sites-available/$siteName-le-ssl.conf ]
		then
			printSuccess "SSL Successful for $siteName"
			continue
		fi
		printFailed "SSL unsuccessful for $siteName"
		printInfo "Make sure your domains A record is pointing to your IP: $serverIP${Rst}"
		exit
	done

	if [ $allSitesCount == -1 ]
	then
		printFailed "SSL Installation failed"
		printInfo "Reasons for failure"
		printInfo "1. You do not have any sites added (use 'easy-apache -a' to add site)"
		printInfo "2. You already have ssl certificates installed"
		printInfo "Please check & run SSL Installation again"
		exit
	fi

	sudo ufw delete allow 'Apache' &> /dev/null
	sudo ufw allow 'Apache Full' &> /dev/null
	printSuccess "Apache Full allowed in ufw"

	echo -e "SSL added to sites:"
	temp=-1
	while [ $temp != $allSitesCount ]
	do
		if [ -e /etc/apache2/sites-available/${allSitesURL[$temp]}-le-ssl.conf ]
		then
			temp=`expr $temp + 1`
			echo -e "https://${allSitesURL[$temp]}"
			continue
		fi
		temp=`expr $temp + 1`
		echo -e "http://"${allSitesURL[$temp]}
	done
}

apacheSSLInstall () {
	apacheInstall
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