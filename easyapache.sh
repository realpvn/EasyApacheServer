source rainbow.sh

echo "Updating Server"
sudo apt update && sudo apt upgrade -y
echo "Server updated"

echo "Cleaning after upgrade"
sudo apt autoremove -y && sudo apt autoclean -y

IP=`curl -s icanhazip.com`
echo -e "Server Public IP: ${Purple}"${IP}${Rst}

scriptDir="./scripts"
chmod +x $scriptDir/server.sh
chmod +x $scriptDir/ssl.sh

while getopts 'fas' flag; do
  case ${flag} in
    f ) $scriptDir/server.sh
        $scriptDir/ssl.sh
        exit;;
	a ) $scriptDir/server.sh
		exit;;
	s ) $scriptDir/ssl.sh
		exit;;
    * ) echo -e "${Green}Usage: easy-apache [options]\nOptions:\n-f:\t(default) Full setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available${Rst}"
       	echo -e "Example\n./easyapache -f   #for full installation i.e Apache & SSL certificate\n./easyapache -as  #for installating Apache server & SSL certificate"
		exit;;
  esac
done
echo -e "${Green}Usage: easy-apache [options]\n-f:\t(default) Full setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available${Rst}"
