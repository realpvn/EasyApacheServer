source rainbow.sh

chmod +x server.sh
chmod +x ssl.sh

while getopts 'fash' flag; do
  case ${flag} in
    f ) ./server.sh
        ./ssl.sh
        exit;;
	a ) ./server.sh
		exit;;
	s ) ./ssl.sh
		exit;;
	h ) echo -e "Usage: easy-apache [options]\nOptions:\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
       	echo -e "\nExample\n./easy-apache -f   #for full installation i.e Apache & SSL certificate\n./easy-apache -as  #for installating Apache server & SSL certificate"
		exit;;
    * ) echo -e "Usage: easy-apache [options]\nOptions:\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
       	echo -e "\nExample\n./easy-apache -f   #for full installation i.e Apache & SSL certificate\n./easy-apache -as  #for installating Apache server & SSL certificate"
		exit;;
  esac
done
echo -e "Usage: easy-apache [options]\nOptions:\n-f:\tFull setup, default option if none is provided\n-a:\tAdding new site (includes apache install)\n-s:\tInstall SSL certificate for sites available\n-h:\tHelp (shows available commands)${Rst}"
echo -e "\nExample\n./easy-apache -f   #for full installation i.e Apache & SSL certificate\n./easy-apache -as  #for installating Apache server & SSL certificate"