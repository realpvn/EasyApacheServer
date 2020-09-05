echo -e "${Bold}${Green}Installing SSL"
sudo add-apt-repository ppa:certbot/certbot
sudo apt install python-certbot-apache -y

allSitesURL=""
allSitesCount=-1

while true
do
    for filePath in /etc/apache2/sites-available/*
    do
        # how below 'cut' command works
        # $filePath will have /etc/apache2/sites-available/example.com.conf
        # first cut will seperate $filePath by '/' and we take everything after field 5 (-f5-) i.e example.com.conf
        # then we cut example.com.conf by '.' and take everything upto field 2 (-f-2) i.e example.com
        siteName=`echo $filePath | cut -d'/' -f5- | cut -d'.' -f-2`
        if [ -e /etc/apache2/sites-available/${siteName}.conf ] && [ ! -e /etc/apache2/sites-available/${siteName}-le-ssl.conf ]
        then
            allSitesCount=`expr $allSitesCount + 1`
            allSitesURL[$allSitesCount]=$siteName
            echo -e ${Purple}`expr $allSitesCount + 1`". "$siteName ${Rst}
        fi
    done
    echo -e "${Purple}99. Exit SSL Installation${Rst}"
    read -p "Select site to apply SSL (eg, to exit: 99):" sslSiteSelect
    if [ $sslSiteSelect == 99 ]
    then
        exit
    fi

    if [ $allSitesCount == -1 ]
    then
        echo -e "${Red}SSL Installation exiting because one of the following were true"
        echo "1. You had no sites added (try running 'easy-apache -a' to add site"
        echo "2. You already have ssl certificates installed"
        echo "Please check & run SSL Installation again${Rst}"
        exit
    fi

    #user inputs 1 for 0(the index) hence we subtract 1 from user input
    sslSiteSelect=`expr $sslSiteSelect-1`
    if [ -e /etc/apache2/sites-available/${allSitesURL[$sslSiteSelect]}.conf ] && [ ! -e /etc/apache2/sites-available/${siteURL[$sslSiteSelect]}-le-ssl.conf ]
    then
        sudo certbot --apache -d www.${siteURL[$sslSiteSelect]} -d ${siteURL[$sslSiteSelect]}
        if [ -e /etc/apache2/sites-available/${siteURL[$sslSiteSelect]}-le-ssl.conf ]
        then
            echo -e "${Bold}${Green}SSL Successful for ${siteURL[$sslSiteSelect]}${Rst}"
            break
        fi
        echo -e "${Bold}${Red}SSL unsuccessful for ${siteURL[$sslSiteSelect]}${Rst}"
        break
    fi
    echo -e "${Bold}${Green}SSL already installed for ${siteURL[$sslSiteSelect]}${Rst}"
done

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