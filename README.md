# EasyApacheServer
Easily setup Apache server by using this script, it takes you step by step and setup everything you need

## How to use this script
#### Step 1
Clone this repository to your server  
```
git clone https://github.com/realpvn/EasyApacheServer.git
```

#### Step 2
Change directory to `EasyApacheServer` and give execute permission for `setup.sh`  
```
cd EasyApacheServer
sudo chmod +x easyapache
```

#### Step 3
Running the script
```
Usage: easyapache [options]
-f:   (default) Full setup, default option if none is provided
-a:   Adding new site (includes apache install)
-s:   Install SSL certificate for sites available"

Example
./easyapache -f   #for full installation i.e Apache & SSL certificate
./easyapache -as  #for installating Apache server & SSL certificate
```


## Works on
- Ubuntu servers  
(will update more once I test)
