deb:
	@echo "Building Debian Package"
	@make -s clean

ifndef DEBEMAIL
	@echo DEBEMAIL="realpvn@gmail.com" >> ~/.bashrc
	@echo DEBFULLNAME="Pavan Kumar" >> ~/.bashrc
	@echo export DEBEMAIL DEBFULLNAME >> ~/.bashrc
	@source ~/.bashrc
endif

	@read -p "Version: " ver; \
	cp easy-apache.sh easy-apache
	dch -v $$ver; \
	dh_make -p easy-apache_$$ver --indep --createorig -c gpl3 -e realpvn@gmail.com
	debuild -S
	@make -s clean
	debuild

clean:
	@echo "Cleaning build"
ifneq ("$(wildcard $(easy-apache))","")
	@rm easy-apache
endif
	
ifneq ("$(wildcard $(../easy-apache_*))","")
	@rm ../easy-apache_*
endif

upload:
	@dput ppa:realpvn/easy-apache easy-apache_*_source.changes