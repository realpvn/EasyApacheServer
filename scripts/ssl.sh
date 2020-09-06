source rainbow.sh
echo -e "${Bold}${Green}Installing SSL${Rst}"
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
        if [ allSitesCount == -1 ]
        then
            exit
        fi
        break
    fi

    if [ ! -e /etc/apache2/sites-available/${siteName}.conf ]
    then
        echo "${siteName} does not exist.\n${Purple}Add it using './easyapache -a'${Rst}"
        continue
    fi

    if [ -e /etc/apache2/sites-available/${siteName}-le-ssl.conf ]
    then
        echo "${Bold}${Green}${siteName} already has SSL installed${Rst}"
        continue
    fi

    allSitesCount=`expr $allSitesCount + 1`
    allSitesURL[$allSitesCount]=$siteName
    echo -e ${Purple}`expr $allSitesCount + 1`". "$siteName ${Rst}
    
    sudo certbot --apache -d www.$siteName -d $siteName
    if [ -e /etc/apache2/sites-available/$siteName-le-ssl.conf ]
    then
        echo -e "${Bold}${Green}SSL Successful for $siteName${Rst}"
        continue
    fi
    echo -e "${Bold}${Red}SSL unsuccessful for $siteName${Rst}, try again"
    exit
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