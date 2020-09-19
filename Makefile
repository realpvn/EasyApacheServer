deb:
	@echo "Building Debian Package"
	@make -s clean

ifndef DEBEMAIL
	@echo DEBEMAIL="realpvn@gmail.com" >> ~/.bashrc
	@echo DEBFULLNAME="Pavan Kumar" >> ~/.bashrc
	@echo export DEBEMAIL DEBFULLNAME >> ~/.bashrc
	@source ~/.bashrc
endif
	@echo Old Version: `head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1 | cut -d '-' -f1`
	@cp easy-apache.sh easy-apache
	@read -p "Version: " ver; \
	dch -v $$ver; \
	dh_make -p easy-apache_$$ver --indep --createorig -c gpl3 -e realpvn@gmail.com
	@debuild -S
	@make -s clean

debBinary:
	@make -s deb
	debuild

clean:
	@echo "Cleaning build"
	@rm -f easy-apache ../easy-apache_*

upload:
	@curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`; \
	dput ppa:realpvn/easy-apache easy-apache_$$curVer_source.changes