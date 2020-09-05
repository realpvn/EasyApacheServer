echo -e "${Bold}${Green}Installing SSL"
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
    read -p "URL (do not add www, eg input - helloworld.com): " siteName
    if [ -e /etc/apache2/sites-available/${siteName}.conf ] && [ ! -e /etc/apache2/sites-available/${siteName}-le-ssl.conf ]
    then
        allSitesCount=`expr $allSitesCount + 1`
        allSitesURL[$allSitesCount]=$siteName
        echo -e ${Purple}`expr $allSitesCount + 1`". "$siteName ${Rst}
        
        sudo certbot --apache -d www.$siteName -d $siteName
        if [ -e /etc/apache2/sites-available/$siteName-le-ssl.conf ]
        then
            echo -e "${Bold}${Green}SSL Successful for $siteName${Rst}"
            break
        fi
        echo -e "${Bold}${Red}SSL unsuccessful for $siteName${Rst}"
        break
    fi
done

if [ $allSitesCount == -1 ]
then
    echo -e "${Red}SSL Installation exiting because one of the following were true"
    echo "1. You had no sites added (try running 'easy-apache -a' to add site"
    echo "2. You already have ssl certificates installed"
    echo "Please check & run SSL Installation again${Rst}"
    exit
fi

echo "Allowing 'Apache Full' in ufw"
sudo ufw delete allow 'Apache'
sudo ufw allow 'Apache Full'

echo "SSL added to sites:"
temp=0
while [ $temp != $allSitesCount ]
do
    if [ -e /etc/apache2/sites-available/${allSitesURL[$temp]}-le-ssl.conf ]
    then
        echo "https://${allSitesURL[$temp]}"
        temp=`expr $temp + 1`
        continue
    fi
    echo "http://"${allSitesURL[$temp]}
    temp=`expr $temp + 1`
done