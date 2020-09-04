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

#********************************************************************************************

clear
echo "Apache Server Setup"

echo "Updating Server"
sudo apt update && sudo apt upgrade -y
echo "Server updated"

echo "Cleaning after upgrade"
sudo apt autoremove -y && sudo apt autoclean -y

IP=`curl -s icanhazip.com`
echo -e "Server Public IP: ${Purple}"${IP}${Rst}

echo "Installing Apache 2"
sudo apt install apache2 -y
echo -e ${Purple}Apache `apache2 -v`"${Rst}"

echo "Checking UFW"
if sudo ufw status | grep -q inactive$; then
    echo -e "${Red}UFW is disabled. You need to enabled it to continue...${Rst}"
    
    # loop until the answer is yes(Yy) or no(Nn)
    while true
    do
        read -p "Do you want to enable (Yy/Nn)? " yn
        case $yn in
            [Yy]* ) sudo ufw enable;
                    echo "UFW enabled. Allowing SSH & Apache"
                    sudo ufw allow ssh;
                    sudo ufw allow Apache;
                    break;;
            [Nn]* ) echo -e "${Red}Setup Failed to complete${Rst}"; exit;;
                * ) echo "Please answer yes(Yy) or no(Nn) ";;
        esac
    done
else
    echo "UFW enabled"
fi

#TODO(pavank): try to check if site is available at ${IP}
read -p "Number of sites to setup (number only)? " numb
temp=0
while [ $temp != $numb ]
do
    echo -e "${Green}===>${Rst} Setting up site `expr $temp + 1`"
    read -p "Site URL (do not add www, eg input - helloworld.com): " readSiteURL

    #storing urls so it can be used when adding SSL certificate
    siteURL[$temp]=$readSiteURL

    #used for directory name (which is without domain TLD, example.com site folder would be "example" not "example.com")
    siteNameNoTLD=`echo $siteURL[$temp] | cut -d'.' -f1`

    sudo mkdir -p /var/www/$siteNameNoTLD
    sudo chown -R $USER:$USER /var/www/$siteNameNoTLD
    sudo chmod -R 755 /var/www

    #create fake page for temporary viewing
    sudo echo "<h1>Server "`expr $temp + 1`" setup by <a href='https://github.com/realpvn/EasyApacheServer.git'>EasyApacheSetup</a> (https://github.com/realpvn/EasyApacheServer.git) </h1>" > /var/www/$siteNameNoTLD/index.html

    echo "Site ${siteURL[$temp]} created, configuring"
    read -p "Email (leave blank if not required):" siteEmail
    if [ -z $siteEmail ]; then
        siteEmail=dev@localhost
    fi
    echo -e "<VirtualHost *:80>\n\tServerAdmin $siteEmail\n\tServerName ${siteURL[$temp]}\n\tServerAlias www.${siteURL[$temp]}\n\tDocumentRoot /var/www/$siteNameNoTLD\n\tErrorLog \${APACHE_LOG_DIR}/error.log\n\tCustomLog \${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" | sudo tee /etc/apache2/sites-available/${siteURL[$temp]}.conf

    echo "Enabling site configuration"
    sudo a2ensite ${siteURL[$temp]}.conf
    temp=`expr $temp + 1`
done

echo "Disabling default site (/var/www/html)"
sudo a2dissite 000-default.conf

read -p "Do you also want to install SSL/TSL certificate (Yy/Nn)?" sslReq
case $sslReq in
    [Yy]* ) sudo add-apt-repository ppa:certbot/certbot
            sudo apt install python-certbot-apache -y
            
            while true
            do
                siteCount=0
                siteNameArr=""
                for filePath in /etc/apache2/sites-available/*
                do
                    # how below 'cut' command works
                    # $filePath will have /etc/apache2/sites-available/example.com.conf
                    # first cut will seperate $filePath by '/' and we take everything after field 5 (-f5-) i.e example.com.conf
                    # then we cut example.com.conf by '.' and take everything upto field 2 (-f-2) i.e example.com
                    siteName=`echo $filePath | cut -d'/' -f5- | cut -d'.' -f-2`
                    if [ -e /etc/apache2/sites-available/${siteName}.conf ] && [ ! -e /etc/apache2/sites-available/${siteName}-le-ssl.conf ]
                    then
                        siteNameArr[$siteCount]=$siteName
                        siteCount=`expr $siteCount + 1`
                        echo -e ${Purple}${siteCount}". "$siteName ${Rst}
                    fi
                done
                
                if [ ! $siteCount > 0 ]
                then
                    echo "${Red}SSL Installation exiting. You do not have sites without SSL or it was not found by the script"
                    echo "Please check if your apache server was setup properly and run SSL Installation again${Rst}"
                    break
                fi

                echo -e "${Purple}99. Exit${Rst}"
                echo "count= ${siteCount}"
                read -p "Select site to apply SSL (eg, to exit: 99):" sslSiteSelect
                if [ $sslSiteSelect == 99 ]
                then
                    break
                fi

                #because index starts from 0, but user inputs 1 for 0 hence we subtract 1 by user input
                sslSiteSelect=`expr $sslSiteSelect-1`
                if [ -e /etc/apache2/sites-available/${siteNameArr[$sslSiteSelect]}.conf ] && [ ! -e /etc/apache2/sites-available/${siteURL[$sslSiteSelect]}-le-ssl.conf ]
                then
                    echo "Allowing 'Apache Full' in ufw"
                    sudo ufw delete allow 'Apache'
                    sudo ufw allow 'Apache Full'
                    sudo certbot --apache -d www.${siteURL[$sslSiteSelect]} -d ${siteURL[$sslSiteSelect]}
                    if [ -e /etc/apache2/sites-available/${siteURL[$sslSiteSelect]}-le-ssl.conf ]
                    then
                        echo -e "${Bold}${Green}SSL Successful for ${siteURL[$sslSiteSelect]}${Rst}"
                        break
                    fi
                    echo -e "${Bold}${Red}SSL unSuccessful for ${siteURL[$sslSiteSelect]}${Rst}"
                    break
                fi
                echo -e "${Bold}${Green}SSL already installed for ${siteURL[$sslSiteSelect]}${Rst}"
            done;;
    [Nn]* ) echo "SSL installation rejected by user";;
    * ) echo "Invalid. Rerun the script to add SSL";;
esac

echo "Restarting Apache2 to activate new configuration"
sudo systemctl restart apache2

echo -e "${Bold}${Green}Success! Your sites have been added successfully.${Rst}"
echo "Point your domains A record to $IP and after DNS propagation everything should be working fine."
echo "Sites added and configured are:"

temp=0
while [ $temp != $numb ]
do
    if [ -e /etc/apache2/sites-available/${siteURL[$temp]}-le-ssl.conf ]
    then
        echo "https://${siteURL[$temp]}"
        temp=`expr $temp + 1`
        continue
    fi
    echo "http://"${siteURL[$temp]}
    temp=`expr $temp + 1`
done
