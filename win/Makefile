include ../config.mk

export \
DESTDIR    = $(WIN_AWEATHER)/build

INSTALLERS = $(FILES)/aweather-$(VER_AWEATHER).exe \
             $(FILES)/aweather-$(VER_AWEATHER)-gtk.exe

all: $(INSTALLERS)  
	@echo all-win

clean:
	@echo clean-win
	rm -rf $(INSTALLERS) $(DESTDIR)

$(DESTDIR):
	make -C $(WIN_AWEATHER) install
	make -C $(WIN_GRITS)    install
	make -C $(WIN_RSL)      install
	find $(DESTDIR) -name '*.a'  -delete
	find $(DESTDIR) -name '*.la' -delete
	rm -rf $(DESTDIR)/share/rsl1/colors
	rm -rf $(DESTDIR)/include
	touch $@

$(INSTALLERS): $(DESTDIR)
	makensis -DROOT=$(WIN_AWEATHER) -DVERSION=$(VER_AWEATHER) aweather.nsi; \
	makensis -DROOT=$(WIN_AWEATHER) -DVERSION=$(VER_AWEATHER) -DUSE_GTK aweather.nsi
	cp $(WIN_AWEATHER)/aweather-$(VERSION)*.exe $(FILES)

aweather-gen:
	cd $(WIN_AWEATHER); \
	PKG_CONFIG_PATH="$(WIN_GRITS)/src" \
	LDFLAGS="-L$(WIN_GRITS)/src/.libs -L$(WIN_RSL)/src/.libs" \
	CPPFLAGS="-I$(WIN_GRITS)/include/grits -I$(WIN_RSL)/src" \
	CFLAGS="-g -Wno-unused -O3" \
	./autogen.sh \
		--enable-relative \
		--enable-shared \
		--disable-static \
		--host=mingw32

grits-gen:
	cd $(WIN_GRITS); \
	./autogen.sh \
		--enable-relative \
		--enable-shared \
		--disable-static \
		--host=mingw32 \
		CFLAGS="-g -Werror -Wno-unused -O3"

rsl-gen:
	cd $(WIN_RSL); \
	./autogen.sh \
		--enable-relative \
		--enable-shared \
		--disable-static \
		--host=mingw32 \
		CFLAGS="-g -Wall -Wno-unused -O3"
