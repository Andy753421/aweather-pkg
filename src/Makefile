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
	PKG_CONFIG_PATH="$(SRC_GRITS)/src" \
	./autogen.sh \
		--enable-gps \
		--datadir="$(SRC_AWEATHER)/data" \
		--libdir="$(SRC_AWEATHER)/src/plugins" \
		CFLAGS="-g -Werror $(CFLAGS)"

grits-gen:
	cd $(SRC_GRITS); \
	./autogen.sh \
		--enable-gtk-doc \
		--includedir="$(SRC_GRITS)/include" \
		--libdir="$(SRC_GRITS)/src/.libs" \
		CFLAGS="-g -Werror $(CFLAGS)"

rsl-gen:
	cd $(SRC_RSL); \
	./autogen.sh \
		--enable-shared \
		--disable-static \
		CFLAGS="-g -Wall -O3"
