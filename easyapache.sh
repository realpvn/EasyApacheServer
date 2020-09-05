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

#***********************************************
# -f (full-setup) : Full setup, default option if none is provided
# -a (add-site) : Adding new site (includes apache install)
# -s (ssl) : Install SSL certificate
#***********************************************
echo "Apache Server Setup"

echo "Updating Server"
sudo apt update && sudo apt upgrade -y
echo "Server updated"

echo "Cleaning after upgrade"
sudo apt autoremove -y && sudo apt autoclean -y

IP=`curl -s icanhazip.com`
echo -e "Server Public IP: ${Purple}"${IP}${Rst}

$scriptDir="./scripts"
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

# read -p "Do you also want to install SSL/TSL certificate (Yy/Nn)?" sslReq
# case $sslReq in
#     [Yy]* ) ./ssh-setup.sh;;
#     [Nn]* ) echo "SSL installation rejected by user";;
#     * ) echo "Invalid. Rerun the script to add SSL";;
# esac
