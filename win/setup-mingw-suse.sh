#!/bin/bash

function setup {
	# Parse args
	bin=false; dev=false;
	eval set -- "`getopt -n "$0" -o bdx -l bin,dev -- "$@"`"
	while [ ! "$1" == "--" ]; do
		case "$1" in
			-b|--bin) bin=true ;;
			-d|--dev) dev=true ;;
		esac
		shift
	done
	url="$SUSE/$2"
	rpm="$PKGS/$2"
	tar="${rpm/.rpm/.tar.gz}"

	# Create paths
	mkdir -p "$PKGS" "$BIN" "$DEV"

	# Download
	if [ ! -f "$rpm" ]; then
		wget -O "$rpm" "$url"
	fi
	if [ ! -f "$tar" ]; then
		tmp=`mktemp -d`
		root="usr/i686-w64-mingw32/sys-root/mingw"
		( cd "$tmp"; rpm2cpio "$rpm" | cpio -id )
		( cd "$tmp/$root"; tar -caf "$tar" * )
		rm -rf "$tmp"
	fi

	# Install
	echo "Installing $2"
	$dev && tar -xa -C "$DEV" -f "$tar" || true
	$bin && tar -xa -C "$BIN" -f "$tar" || true
}

# Install custom programs
#   grits    - DESTDIR=/usr/$MINGW make install
#   rsl      - DESTDIR=/usr/$MINGW make install
#   aweather - DESTDIR=/usr/$MINGW make install

set -e

# Install locations
GCC="mingw32-gcc"
CLEAN="/usr/mingw32-clean"
SUSE='http://download.opensuse.org/repositories/windows:/mingw:/win32/openSUSE_Factory/noarch'
PKGS="/home/andy/src/aweather-win32/local/packages"
DEV="/usr/mingw32-suse"
BIN="/home/andy/src/aweather-win32/local/gtk-suse"

# Setup dev folder
rsync -a --delete "$CLEAN/" "$DEV/"

# Install packages
setup -bd "mingw32-zlib-1.2.7-1.116.noarch.rpm"
setup -bd "mingw32-libcairo2-1.10.2-8.116.noarch.rpm"
setup -bd "mingw32-libpng-1.5.11-1.98.noarch.rpm"
setup -bd "mingw32-freetype-2.4.10-1.97.noarch.rpm"
setup -bd "mingw32-fontconfig-2.10.1-1.82.noarch.rpm"
setup -bd "mingw32-libexpat-2.0.1-4.267.noarch.rpm"
setup -bd "mingw32-libbz2-1.0.6-3.254.noarch.rpm"
setup -bd "mingw32-pixman-0.26.0-1.108.noarch.rpm"
setup -bd "mingw32-libsoup-2.38.1-1.110.noarch.rpm"
setup -bd "mingw32-libxml2-2.8.0-2.59.noarch.rpm"
setup -bd "mingw32-libintl-0.18.1.1-13.242.noarch.rpm"
setup -bd "mingw32-libjpeg-8d-3.101.noarch.rpm"
setup -bd "mingw32-libffi-3.0.10-2.203.noarch.rpm"
setup -bd "mingw32-libjasper-1.900.1-6.239.noarch.rpm"
setup -bd "mingw32-libtiff-4.0.2-1.88.noarch.rpm"
setup -bd "mingw32-liblzma-5.0.4-1.92.noarch.rpm"
setup -bd "mingw32-glib2-2.34.1-1.33.noarch.rpm"
setup -bd "mingw32-atk-2.6.0-1.53.noarch.rpm"
setup -bd "mingw32-pango-1.30.1-1.64.noarch.rpm"
setup -bd "mingw32-gdk-pixbuf-2.26.3-1.63.noarch.rpm"
setup -bd "mingw32-gtk2-2.24.14-1.8.noarch.rpm"

setup -d  "mingw32-zlib-devel-1.2.7-1.116.noarch.rpm"
setup -d  "mingw32-cairo-devel-1.10.2-8.116.noarch.rpm"
setup -d  "mingw32-libpng-devel-1.5.11-1.98.noarch.rpm"
setup -d  "mingw32-freetype-devel-2.4.10-1.97.noarch.rpm"
setup -d  "mingw32-fontconfig-devel-2.10.1-1.82.noarch.rpm"
setup -d  "mingw32-libexpat-devel-2.0.1-4.267.noarch.rpm"
setup -d  "mingw32-libbz2-devel-1.0.6-3.254.noarch.rpm"
setup -d  "mingw32-pixman-devel-0.26.0-1.108.noarch.rpm"
setup -d  "mingw32-libsoup-devel-2.38.1-1.110.noarch.rpm"
setup -d  "mingw32-libxml2-devel-2.8.0-2.59.noarch.rpm"
setup -d  "mingw32-libintl-devel-0.18.1.1-13.242.noarch.rpm"
setup -d  "mingw32-libjpeg-devel-8d-3.101.noarch.rpm"
setup -d  "mingw32-libffi-devel-3.0.10-2.203.noarch.rpm"
setup -d  "mingw32-libjasper-devel-1.900.1-6.239.noarch.rpm"
setup -d  "mingw32-libtiff-devel-4.0.2-1.88.noarch.rpm"
setup -d  "mingw32-liblzma-devel-5.0.4-1.92.noarch.rpm"
setup -d  "mingw32-glib2-devel-2.34.1-1.33.noarch.rpm"
setup -d  "mingw32-atk-devel-2.6.0-1.53.noarch.rpm"
setup -d  "mingw32-pango-devel-1.30.1-1.64.noarch.rpm"
setup -d  "mingw32-gdk-pixbuf-devel-2.26.3-1.63.noarch.rpm"
setup -d  "mingw32-gtk2-devel-2.24.14-1.8.noarch.rpm"

# Cleanup install folders
echo "Cleaning install folders"
rm  -f $DEV/lib/*.la
rm -rf $BIN/{contrib,include,man,manifest,src,*.txt}
rm -rf $BIN/share/{aclocal,glib,gtk,locale,man,doc}*
rm  -f $BIN/lib/GNU.Gettext.dll
rm -rf $BIN/etc/bash_completion.d
find "$BIN/bin/" "$BIN/lib/" -type f \
	-and -not -name '*.dll'      \
	-and -not -name '*.cache'    \
	-and -not -name 'gspawn-*'   \
	-delete
find "$BIN/bin/" "$BIN/lib/" -type f \
	-and -not -name 'libxml*dll' \
	-and -not -name 'iconv.dll'  \
	-exec strip -s "{}" ";"
find "$BIN" -type d -delete 2>/dev/null || true

# Working xdg-open
echo "Building xdg-open"
$GCC -Wall -mwindows -o $BIN/bin/xdg-open.exe xdg-open.c

# Custom settings
echo "Adding custom settings"
mkdir -p $BIN/etc/{gtk-2.0,pango}
cp gtkrc2        $BIN/etc/gtk-2.0/gtkrc
cp pango.aliases $BIN/etc/pango/pango.aliases

# Fix pkg-config
echo "Fixing pkg-config"
sed -i "s!^prefix=.*!prefix=$DEV!" $DEV/lib/pkgconfig/*.pc
