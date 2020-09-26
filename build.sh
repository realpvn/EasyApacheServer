clean () {
    echo "Cleaning build"
    rm -f easy-apache ../easy-apache_*
    git checkout debian/changelog
}

build () {
    echo "Building Debian Package"
    clean
    cp easy-apache.sh easy-apache
    oldVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`
    echo Old Version: $oldVer
    read -p "New Version: " ver
    dch -v $ver
    curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1 | cut -d '-' -f1`
    dh_make -p easy-apache_$curVer --indep --createorig -c gpl3 -e realpvn@gmail.com
}

source () {
    build
    debuild -S
    read -p "Do you want to upload? (Y/N): " verCheck
    case $verCheck in
        [Yy]* ) upload;;
    esac
}

binary () {
    build
    debuild
}

upload () {
    curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`
    echo "Current version: $curVer"
    read -p "Is the current version correct? (Y/N): " verCheck
    case $verCheck in
        [Yy]* ) echo "Starting Upload"
                cd ..
                dput ppa:realpvn/easy-apache easy-apache_${curVer}_source.changes;;
        [Nn]* ) echo "Terminating upload";;
            * ) echo "Wrong input";;
    esac
}

while getopts 'scub' flag
do
    case $flag in 
        s ) source
            exit;;
        c ) clean
            exit;;
        u ) upload
            exit;;
        b ) binary
            exit;;
        * ) echo "Use option -s to build deb source Package"
    esac
done
echo "Use option -s to build deb source Package"