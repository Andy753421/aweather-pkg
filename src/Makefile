include ../config.mk

PACKAGES = $(FILES)/aweather-$(VER_AWEATHER).tar.gz \
           $(FILES)/grits-$(VER_GRITS).tar.gz \
           $(FILES)/rsl-$(VER_RSL).tar.gz

all: $(PACKAGES)
	@echo all-src

clean:
	@echo clean-src
	rm -f $(PACKAGES)

$(PACKAGES):
	make -C $(SRC_AWEATHER) dist
	make -C $(SRC_GRITS)    dist
	make -C $(SRC_RSL)      dist
	cp -t $(FILES) \
		$(SRC_AWEATHER)/aweather-$(VER_AWEATHER).tar.gz \
		$(SRC_GRITS)/grits-$(VER_GRITS).tar.gz \
		$(SRC_RSL)/rsl-$(VER_RSL).tar.gz

aweather-gen:
	cd $(SRC_AWEATHER); \
	PKG_CONFIG_PATH="$(MAC_GRITS)" \
	LIBS="-L$(MAC_GRITS)" \
	CPPFLAGS="-I$(MAC_GRITS)" \
	./autogen.sh \
		--enable-shared \
		--disable-static \
		CFLAGS="-g -Werror $CFLAGS"

grits-gen:
	cd $(SRC_GRITS); \
	./autogen.sh \
		"--enable-gtk-doc" \
		"--libdir=$(SRC_GRITS)/src/.libs" \
		"--includedir=$(SRC_GRITS)/include" \
		CFLAGS="-g -Werror $(CFLAGS)"
