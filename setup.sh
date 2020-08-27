# Colors from - https://github.com/ItsJimi/rainbow.sh
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

IP=`curl -s icanhazip.com`
echo -e "Server Public IP found: ${Purple}"${IP}${Rst}

echo "Installing Apache 2"
sudo apt install apache2
echo -e "Apache version installed: ${Purple}"`apache2 -v`"${Rst}"
sudo ufw allow 'Apache'

echo "Checking UFW"
if sudo ufw status | grep -q inactive$; then
    echo -e "${Red}UFW is disabled. You need to enabled it to continue...${Rst}"
    
    # loop until the answer is yes(Yy) or no(Nn)
    while true; do
        read -p "Do you want to enable (Yy/Nn)? " yn
        case $yn in
            [Yy]* ) echo "XXX Enable ufw";
                    sudo ufw allow ssh;
                    sudo ufw allow Apache;
                    break;;
            [Nn]* ) echo -e "${Red}Setup Failed to complete${Rst}"; exit;;
                * ) echo "Please answer yes(Yy) or no(Nn) ";;
        esac
    done
else
    echo -e "${Green}UFW is enabled"
fi

#TODO(pavank): try to check if site is available at ${IP}
read -p "Total sites you want to setup (number only)? " numb
temp=0
while [ $temp != $numb ]
do
    echo "===> Now Setting up "`expr $temp + 1`" site"
    read -p "Site URL (do not add www, eg input - helloworld.com): " readSiteURL

    #storing urls so it can be used when adding SSL certificate
    siteURL[$temp]=$readSiteURL

    sudo mkdir -p /var/www/$siteURL/public_html
    sudo chown -R $USER:$USER /var/www/${siteURL[$temp]}/public_html
    sudo chmod -R 755 /var/www

    #create fake page for temporary viewing
    sudo echo "<h1>Server "`expr $temp + 1`" setup by XXXXXXXXXX </h1>" > /var/www/${siteURL[$temp]}/public_html/index.html

    echo -e "${Green}Site ${siteURL[$temp]} created, configuring"
    read -p "Email (to receive notifications for ${siteURL[$temp]}, leave blank if not required):" siteEmail
    sudo echo "
        <VirtualHost *:80>
            ServerAdmin $siteEmail
            ServerName ${siteURL[$temp]}
            ServerAlias www.${siteURL[$temp]}
            DocumentRoot /var/www/${siteURL[$temp]}/public_html
            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined
        </VirtualHost>
    " > /etc/apache2/sites-available/${siteURL[$temp]}.conf

    echo "Enabling site configuration"
    sudo a2ensite ${siteURL[$temp]}.conf
    temp=`expr $temp + 1`
done

echo "Disabling default site (/var/www/html)"
sudo a2dissite 000-default.conf

echo "Restarting Apache2 to activate new configuration"
sudo systemctl restart apache2

echo -e "${Bold}${Green}Success! Your sites have been added successfully. Visit below links to confirm"
for a in 0 1
do
    echo -e "${Green}http://"${siteURL[$a]}
done

#TODO(pavank): add SSL certificate setup if required