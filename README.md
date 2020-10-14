# Easy Apache
Easily setup Apache server by using this script, it takes you step by step and setup everything you need

## Install
Installing easy-apache on to your server is easy too. Just copy & paste below command(s) to your server terminal
##### Using apt
```
sudo add-apt-repository ppa:realpvn/easy-apache
sudo apt update
sudo apt install easy-apache
```
## Run
One command to setup everything, installs Apache & SSL
```
easy-apache -f
```
That is it! 🤩
  
  
## Options & Usage
```
Usage:
easy-apache [options]

Options:
-f | --full:            Full setup, default option if none is provided
-a | --apache:          Adding new site (includes apache install)
-s | --SSL:             Install SSL certificate for sites available
-h | --help:            Help (shows available commands)

Example
easy-apache -f                  #for full installation i.e Apache & SSL certificate
easy-apache --full              #for full installation i.e Apache & SSL certificate
easy-apache -a                  #for installating Apache server
easy-apache -s                  #for installating SSL certificate
```


## Works on
- Ubuntu 20.04 (focal)  
(will update more once I test)
