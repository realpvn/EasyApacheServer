source rainbow.sh

scriptDir="./scripts"
chmod +x $scriptDir/server.sh
chmod +x $scriptDir/ssl.sh

while getopts 'fash' flag; do
  case ${flag} in
    f ) $scriptDir/server.sh
        $scriptDir/ssl.sh
        exit;;
	a ) $scriptDir/server.sh
		exit;;
	s ) $scriptDir/ssl.sh
		exit;;
	h ) echo -e "${Green}Usage: easy-apache [options]\nOptions:\n-f:\t(default) Full setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available${Rst}"
       	echo -e "Example\n./easyapache -f   #for full installation i.e Apache & SSL certificate\n./easyapache -as  #for installating Apache server & SSL certificate"
		exit;;
    * ) echo -e "${Green}Usage: easy-apache [options]\nOptions:\n-f:\t(default) Full setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available${Rst}"
       	echo -e "Example\n./easyapache -f   #for full installation i.e Apache & SSL certificate\n./easyapache -as  #for installating Apache server & SSL certificate"
		exit;;
  esac
done
echo -e "${Green}Usage: easy-apache [options]\n-f:\t(default) Full setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available${Rst}"
