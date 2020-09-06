source rainbow.sh
echo -e "${Bold}${Green}Installing Apache${Rst}"
allSitesURL=""
allSitesCount=-1

dpkg -s apache2 &> /dev/null
if [ $? -eq 1 ]; then
    echo "Installing Apache 2"
    sudo apt install apache2 -y
    echo -e ${Purple}Apache `apache2 -v`"${Rst}"
fi

while true
do
    echo -e "${Green}===>${Rst} Setting up new site"
    read -p "URL (do not add www, eg input - helloworld.com): " siteURL

    if [ -e /etc/apache2/sites-available/$siteURL.conf ]
    then
        echo -e "${Red}$siteURL already exists, do you want to overwrite (Yy/Nn/99 to exit setup)?${Rst}"
        read overwriteSite
        case $overwriteSite in
            [Yy]* ) #allSitesURL used for printing at last
                    allSitesCount=`expr $allSitesCount + 1`
                    allSitesURL[$allSitesCount]=$siteURL
                    
                    #used for directory name (which is without domain TLD, example.com site folder would be "example" not "example.com")
                    siteNameNoTLD=`echo $siteURL | cut -d'.' -f1`

                    sudo mkdir -p /var/www/$siteNameNoTLD
                    sudo chown -R $USER:$USER /var/www/$siteNameNoTLD
                    sudo chmod -R 755 /var/www

                    #create temporary index.html page for viewing
                    sudo echo "<h1>Server setup by <a href='https://github.com/realpvn/EasyApacheServer.git'>EasyApacheSetup</a> (https://github.com/realpvn/EasyApacheServer.git) </h1>" > /var/www/$siteNameNoTLD/index.html

                    echo "Site $siteURL created, configuring"
                    read -p "Email (leave blank if not required):" siteEmail
                    if [ -z $siteEmail ]; then
                        siteEmail=dev@localhost
                    fi
                    echo -e "<VirtualHost *:80>\n\tServerAdmin $siteEmail\n\tServerName $siteURL\n\tServerAlias www.$siteURL\n\tDocumentRoot /var/www/$siteNameNoTLD\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" | sudo tee /etc/apache2/sites-available/$siteURL.conf

                    echo "Enabling site configuration"
                    sudo a2ensite $siteURL.conf
                    break;;
            [Nn]* ) continue;;
            [99]*  ) break;;
                * ) echo -e "${Red}Invalid input. Skipping $siteURL setup"
                    continue;;
        esac
    fi
done

if [ $allSitesCount == -1 ]
then
    echo "${Red}Exiting EasyApache. No Sites were added${Rst}"
    exit
fi

echo "Checking UFW"
if sudo ufw status | grep -q inactive$
then
    echo -e "${Red}UFW is disabled. You need to enable it to continue...${Rst}"
    
    while true
    do
        read -p "Do you want to enable now (Yy/Nn)? " ufwEnable
        case $ufwEnable in
            [Yy]* ) sudo ufw enable;
                    echo "UFW enabled. Allowing SSH & Apache ports"
                    sudo ufw allow ssh;
                    sudo ufw allow Apache;
                    break;;
            [Nn]* ) echo -e "${Red}You cannot view the site until you enable ufw and allow SSH & Apache${Rst}"; break;;
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

echo -e "${Bold}${Green}Success! Your site(s) have been added successfully"
echo -e "Point your domains A record to $IP and after DNS propagation everything should be working fine.${Rst}"
echo "Sites added and configured are:"

temp=-1
while [ $temp != $allSitesCount ]
do
    temp=`expr $temp + 1`
    echo "http://"${allSitesURL[$temp]}
done