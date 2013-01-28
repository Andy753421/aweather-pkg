#!/bin/bash

function extract {
	bin=false; dev=false; ext=false;
	eval set -- "`getopt -n "$0" -o bdx -l bin,dev,ext -- "$@"`"
	while [ ! "$1" == "--" ]; do
		case "$1" in
			-b|--bin) bin=true ;;
			-d|--dev) dev=true ;;
			-x|--ext) ext=true ;;
		esac
		shift
	done

	zip=$2
	sub=$(basename "${zip/.zip/}")
	tmp=`mktemp -d`
	$ext && unzip "$zip" -d "$tmp/$sub" \
	     || unzip "$zip" -d "$tmp"
	$dev && rsync -a "$tmp/$sub/" "$DEV/"
	$bin && rsync -a "$tmp/$sub/" "$BIN/"
	rm -rf "$tmp"
}

# Install custom programs
#   grits    - DESTDIR=/usr/$MINGW make install
#   rsl      - DESTDIR=/usr/$MINGW make install
#   aweather - DESTDIR=/usr/$MINGW make install

# Download locations
GTK3_URI='http://www.tarnyko.net/repo/GTK+-Bundle-3.6.1_(TARNYKO).exe'
SOUP_BIN='http://ftp.gnome.org/pub/gnome/binaries/win32/libsoup/2.26/libsoup_2.26.3-1_win32.zip'
SOUP_DEV='http://ftp.gnome.org/pub/gnome/binaries/win32/libsoup/2.26/libsoup-dev_2.26.3-1_win32.zip'
BZIP_BIN='http://downloads.sourceforge.net/project/gnuwin32/bzip2/1.0.5/bzip2-1.0.5-bin.zip'
BZIP_DEV='http://downloads.sourceforge.net/project/gnuwin32/bzip2/1.0.5/bzip2-1.0.5-lib.zip'

# Install locations
GCC="mingw32-gcc"
CLEAN="/usr/mingw32-clean"
PKGS="/home/andy/src/aweather-win32/local/packages"
WINE="/home/andy/.wine/drive_c/Program Files (x86)/GTK+-Bundle-3.6.1"
DEV="/usr/mingw32-3.6"
BIN="/home/andy/src/aweather-win32/local/gtk-3.6"

# Create download dir, if needed
mkdir -p $PKGS

# Download packages
wget -O "$PKGS/$(basename $GTK3_URI)" "$GTK3_URI"
wget -O "$PKGS/$(basename $SOUP_BIN)" "$SOUP_BIN"
wget -O "$PKGS/$(basename $SOUP_DEV)" "$SOUP_DEV"
wget -O "$PKGS/$(basename $BZIP_BIN)" "$BZIP_BIN"
wget -O "$PKGS/$(basename $BZIP_DEV)" "$BZIP_DEV"

# Setup dev folder
rsync -a --delete "$CLEAN/" "$DEV/"

# Install GTK Bundle
wine extern/gtk-3.6.1-dev.exe

# Copy GTK Bundle
rsync -a          "$WINE/"   "$DEV/"
rsync -a --delete "$WINE/"   "$BIN/"

# Extract packages
extract -bdx "$PKGS/$(basename $SOUP_BIN)"
extract -dx  "$PKGS/$(basename $SOUP_DEV)"
extract -bdx "$PKGS/$(basename $BZIP_BIN)"
extract -dx  "$PKGS/$(basename $BZIP_DEV)"

# Cleanup install folders
rm  -f $DEV/lib/*.la
rm -rf $BIN/{contrib,include,man,manifest,*.exe}
rm -rf $BIN/share/{aclocal,bash,doc,gdb,glib,gtk,info,locale,man}*
rm  -f $BIN/lib/GNU.Gettext.dll
find "$BIN/bin/" "$BIN/lib/" -type f \
	-and -not -name '*.dll'      \
	-and -not -name '*.cache'    \
	-and -not -name 'gspawn-*'   \
	-delete
find "$BIN/bin/" "$BIN/lib/" -type f \
	-and -not -name 'libxml*dll' \
	-and -not -name 'iconv.dll'  \
	-exec strip -s "{}" ";"
find "$BIN" -type d -delete 2>/dev/null

# Working xdg-open
$GCC -Wall -mwindows -o $BIN/bin/xdg-open.exe xdg-open.c

# Custom settings
mkdir -p $BIN/etc/{gtk-3.0,pango}
cp gtkrc3        $BIN/etc/gtk-3.0/gtkrc
cp pango.aliases $BIN/etc/pango/pango.aliases

# Fix pkg-config
sed -i "s!^prefix=.*!prefix=$DEV!" $DEV/lib/pkgconfig/*.pc
