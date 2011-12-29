include ../config.mk

DESTDIR  = $(MAC_AWEATHER)/build
PACKAGES = $(FILES)/aweather-$(VER_AWEATHER).dmg
GTKINST  = /Users/andy/gtk/inst
export DESTDIR GTKINST MAC_AWEATHER

all-mac: $(PACKAGES)
	@echo all-mac

$(DESTDIR): $(MAC_AWEATHER)/src/aweather
	make -C $(MAC_AWEATHER) install
	make -C $(MAC_GRITS)    install
	make -C $(MAC_RSL)      install
	find $(DESTDIR) -name '*.a'  -delete
	find $(DESTDIR) -name '*.la' -delete
	rm -rf $(DESTDIR)/share/rsl/colors
	rm -rf $(DESTDIR)/include
	touch $@

$(PACKAGES): $(DESTDIR)
	rsync -uav $(DESTDIR)/ $(GTKINST)/
	jhbuild run gtk-mac-bundler aweather.bundle
	create-dmg --volname 'AWeather-$(VER_AWEATHER)' \
		$(MAC_AWEATHER)/aweather-$(VER_AWEATHER).dmg \
		$(MAC_AWEATHER)/AWeather.app
	$(MAC_AWEATHER)/aweather-$(VER_AWEATHER).dmg
	cp $(FILES)

aweather-gen:
	PKG_CONFIG_PATH="../grits/src/" \
	./autogen.sh "--enable-relative" \
		CFLAGS="-g -Werror $(CFLAGS)"

grits-gen:
	./autogen.sh \
		--enable-shared \
		--disable-static \
		"--libdir=$(MAC_GRITS)/src/.libs" \
		"--includedir=$(MAC_GRITS)/include" \
		CFLAGS="-g -Werror"
