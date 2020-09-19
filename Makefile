deb:
	@echo "Building Debian Package"
	@make -s clean
	@echo Old Version: `head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`
	@cp easy-apache.sh easy-apache
	@read -p "Version: " ver; \
	dch -v $$ver;
	@echo "done"
	@curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`; \
	echo dh_make -p easy-apache_$$curVer --indep --createorig -c gpl3 -e realpvn@gmail.com
	@make -s debSource

debSource:
	@debuild -S

debBinary:
	@make -s deb
	@debuild
	@make -s clean

clean:
	@echo "Cleaning build"
	@rm -f easy-apache ../easy-apache_*
	@git checkout debian/changelog

upload:
	@curVer=`head -1 debian/changelog | cut -d '(' -f2 | cut -d ')' -f1`; \
	dput ppa:realpvn/easy-apache easy-apache_$$curVer_source.changes