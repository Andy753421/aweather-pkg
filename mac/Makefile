include ../config.mk

DESTDIR  = $(MAC_AWEATHER)/build
SRCDMG   = $(MAC_AWEATHER)/aweather-$(VER_AWEATHER).dmg
PACKAGES = $(FILES)/aweather-$(VER_AWEATHER).dmg
GTKINST  = /Users/andy/gtk/inst
export DESTDIR GTKINST MAC_AWEATHER

all-mac: $(PACKAGES)
	@echo all-mac

clean:
	rm -rf $(PACKAGES) $(SRCDMG) \
		$(DESTDIR) $(MAC_AWEATHER)/AWeather.app

$(PACKAGES): $(DESTDIR)
	rm -f $(SRCDMG)
	ln -sf /usr/bin/open $(GTKINST)/bin/xdg-open
	rsync -uav $(DESTDIR)/ $(GTKINST)/
	jhbuild run gtk-mac-bundler aweather.bundle
	create-dmg --volname 'AWeather-$(VER_AWEATHER)' \
		$(SRCDMG) $(MAC_AWEATHER)/AWeather.app
	cp $(SRCDMG) $(FILES)

$(DESTDIR): $(MAC_AWEATHER)/src/aweather \
            $(MAC_GRITS)/src/libgrits.la \
            $(MAC_RSL)/src/librsl.la
	make -C $(MAC_AWEATHER) install
	make -C $(MAC_GRITS)    install
	make -C $(MAC_RSL)      install
	find $(DESTDIR) -name '*.a'  -delete
	find $(DESTDIR) -name '*.la' -delete
	rm -rf $(DESTDIR)/share/rsl1/colors
	rm -rf $(DESTDIR)/include
	touch $@

aweather-build $(MAC_AWEATHER)/src/aweather: \
		$(MAC_GRITS)/src/libgrits.la \
		$(MAC_RSL)/src/librsl.la
	jhbuild run make -C $(MAC_AWEATHER) -j8

grits-build $(MAC_GRITS)/src/libgrits.la:
	jhbuild run make -C $(MAC_GRITS) -j8

rsl-build $(MAC_RSL)/src/librsl.la:
	jhbuild run make -C $(MAC_RSL)

aweather-gen:
	cd $(MAC_AWEATHER); \
	PKG_CONFIG_PATH="$(MAC_GRITS)/src" \
	LDFLAGS="-L$(MAC_GRITS)/src/.libs -L$(MAC_RSL)/src/.libs" \
	CPPFLAGS="-I$(MAC_GRITS)/include/grits -I$(MAC_RSL)/src" \
	jhbuild run ./autogen.sh \
		--enable-relative \
		--enable-shared \
		--disable-static \
		CFLAGS="-g -Werror -Os"

grits-gen:
	cd $(MAC_GRITS); \
	jhbuild run ./autogen.sh \
		--enable-relative \
		--enable-shared \
		--disable-static \
		CFLAGS="-g -Werror -Os"

rsl-gen:
	cd $(MAC_RSL); \
	jhbuild run ./autogen.sh \
		--enable-relative \
		--enable-shared \
		--disable-static \
		CFLAGS="-g -Wall -Wno-unused -Os"
