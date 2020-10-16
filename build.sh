curVer=0
fullCurVer=0
updateDebVersion() {
    oldVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`
    echo Old Version: $oldVer
    read -p "New Version: " ver
    dch -v $ver
}

currentVersion() {
    fullCurVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`
    curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1 | cut -d '-' -f1`
}

makeDeb () {
    echo "Running make"
    clean
    cp easy-apache.sh easy-apache
    read -p "Have you updated version? (Y/N): " verUpdate
    case $verUpdate in
        [Yy]* ) echo "Continuing....";;
        [Nn]* ) read -p "Do you want to update version now? (Y/N): " verUpdate;
                case $verUpdate in
                    [Yy]* ) updateDebVersion;;
                    [Nn]* ) echo "You have to update version to continue";
                            exit;;
                        * ) echo "Invalid input";
                            exit;;
                esac;;
            * ) exit;;
    esac
    currentVersion
    dh_make -p easy-apache_$curVer --indep --createorig -c gpl3 -e realpvn@gmail.com
}

buildDebSource () {
    makeDeb
    debuild -S
    read -p "Do you want to upload Package to PPA? (Y/N): " wantUpload
    case $wantUpload in
        [Yy]* ) uploadPPA;;
    esac
}

buildDebBinary () {
    echo "Note: Binary is only to use in github or distribute. Binary can't be uploaded to PPA"
    read -p "This will deleted any deb source files, do you want to proceed? (Y/N): " cleanNow
    case $cleanNow in
        [Yy]* ) echo "Continuing....";;
        [Nn]* ) echo "You must clean to build binary, exiting..."
                exit;;
            * ) exit;;
    esac
    makeDeb
    debuild
}

buildSnap() {
    cp easy-apache.sh snap/
    cd snap
    snapcraft
}

debug() {
    if [[ -e ../easy-apache_$fullCurVer.dsc ]]
    then
        echo "Debugging .dsc file"
        lintian ../easy-apache_$fullCurVer.dsc
        echo "----------------------"
        lintian ../easy-apache_${fullCurVer}_all.deb
    else
        echo "You need to build before debugging"
    fi
}

clean () {
    echo "Cleaning build"
    rm -f easy-apache ../easy-apache_*
}

uploadPPA () {
    echo "Current version: $fullCurVer"
    read -p "Is the current version correct? (Y/N): " verCheck
    case $verCheck in
        [Yy]* ) echo "Starting Upload"
                cd ..
                dput ppa:realpvn/easy-apache easy-apache_${fullCurVer}_source.changes;;
        [Nn]* ) echo "Terminating upload";;
            * ) echo "Wrong input";;
    esac
}

if [ "$1" != "" ]
then
    currentVersion
    PARAM=$1
    case $PARAM in
        -ds | --debSource ) buildDebSource;
                            exit;;
        -db | --debBinary ) buildDebBinary;
                            exit;;
        -sn | --snap      ) buildSnap;
                            exit;;
        -c  | --clean     ) clean;
                            exit;;
        -d  | --debug     ) debug;
                            exit;;
        -u | --uploadPPA  ) uploadPPA;
                            exit;;
                        * ) echo -e "Usage:\n-ds | --debSource:\t Generates debian source file\n-db | --debBinary:\t Generates debian binary file\n-sn | --snap:\t\t Generates Snap Package\n-c | --clean:\t\t Cleans directory, removes all build files etc\n-u | --uploadPPA:\t Uploads source file to PPA";
                            exit;;
    esac
fi
echo -e "Usage:\n-ds | --debSource:\t Generates debian source file\n-db | --debBinary:\t Generates debian binary file\n-sn | --snap:\t Generates Snap Package\n-c | --clean:\t\t Cleans directory, removes all build files etc\n-u | --uploadPPA:\t Uploads source file to PPA";