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
	h ) echo -e "Usage: easy-apache [options]\nOptions:\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
       	echo -e "\nExample\n./easyapache -f   #for full installation i.e Apache & SSL certificate\n./easyapache -as  #for installating Apache server & SSL certificate"
		exit;;
    * ) echo -e "Usage: easy-apache [options]\nOptions:\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
       	echo -e "\nExample\n./easyapache -f   #for full installation i.e Apache & SSL certificate\n./easyapache -as  #for installating Apache server & SSL certificate"
		exit;;
  esac
done
echo -e "Usage: easy-apache [options]\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
echo -e "\nExample\n./easyapache -f   #for full installation i.e Apache & SSL certificate\n./easyapache -as  #for installating Apache server & SSL certificate"