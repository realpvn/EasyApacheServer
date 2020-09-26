deb:
	@echo "Building Debian Package"
	@make -s debRemove
	@cp easy-apache.sh easy-apache
	@echo Old Version: `head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`
	@read -p "Version: " ver; \
	dch -v $$ver;
	@curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1 | cut -d '-' -f1`; \
	dh_make -p easy-apache_$$curVer --indep --createorig -c gpl3 -e realpvn@gmail.com
	@make -s debSource

debSource:
	@debuild -S

debBinary:
	@make -s deb
	@debuild
	@make -s debRemove

debRemove:
	@echo "Cleaning build"
	@rm -f easy-apache ../easy-apache_*
	@git checkout debian/changelog

upload:
	@curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`; \
	dput ppa:realpvn/easy-apache easy-apache_$$curVer_source.changes