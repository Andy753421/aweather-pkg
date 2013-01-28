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
GTK2_URI='http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/gtk+-bundle_2.24.10-20120208_win32.zip'
SOUP_BIN='http://ftp.gnome.org/pub/gnome/binaries/win32/libsoup/2.26/libsoup_2.26.3-1_win32.zip'
SOUP_DEV='http://ftp.gnome.org/pub/gnome/binaries/win32/libsoup/2.26/libsoup-dev_2.26.3-1_win32.zip'
BZIP_BIN='http://downloads.sourceforge.net/project/gnuwin32/bzip2/1.0.5/bzip2-1.0.5-bin.zip'
BZIP_DEV='http://downloads.sourceforge.net/project/gnuwin32/bzip2/1.0.5/bzip2-1.0.5-lib.zip'
ICNV_URI='http://www.xmlsoft.org/sources/win32/iconv-1.9.2.win32.zip'
XML2_URI='http://www.xmlsoft.org/sources/win32/libxml2-2.7.8.win32.zip'
GLUT_URI='http://files.transmissionzero.co.uk/software/development/GLUT/freeglut-MinGW-2.8.0-1.mp.zip'

# Install locations
GCC="mingw32-gcc"
CLEAN="/usr/mingw32-clean"
PKGS="/home/andy/src/aweather-win32/local/packages"
DEV="/usr/mingw32-2.24"
BIN="/home/andy/src/aweather-win32/local/gtk-2.24"

# Create download dir, if needed
mkdir -p $PKGS

# Download packages
wget -O "$PKGS/$(basename $GTK2_URI)" "$GTK2_URI"
wget -O "$PKGS/$(basename $SOUP_BIN)" "$SOUP_BIN"
wget -O "$PKGS/$(basename $SOUP_DEV)" "$SOUP_DEV"
wget -O "$PKGS/$(basename $BZIP_BIN)" "$BZIP_BIN"
wget -O "$PKGS/$(basename $BZIP_DEV)" "$BZIP_DEV"
wget -O "$PKGS/$(basename $ICNV_URI)" "$ICNV_URI"
wget -O "$PKGS/$(basename $XML2_URI)" "$XML2_URI"
wget -O "$PKGS/$(basename $GLUT_URI)" "$GLUT_URI"

# Setup dev folder
rsync -a --delete "$CLEAN/" "$DEV/"

# Extract packages
extract -bdx "$PKGS/$(basename $GTK2_URI)"
extract -bdx "$PKGS/$(basename $SOUP_BIN)"
extract -dx  "$PKGS/$(basename $SOUP_DEV)"
extract -bdx "$PKGS/$(basename $BZIP_BIN)"
extract -dx  "$PKGS/$(basename $BZIP_DEV)"
extract -bd  "$PKGS/$(basename $ICNV_URI)"
extract -bd  "$PKGS/$(basename $XML2_URI)"
extract -dx  "$PKGS/$(basename $GLUT_URI)"

# Cleanup install folders
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
find "$BIN" -type d -delete 2>/dev/null

# Working xdg-open
$GCC -Wall -mwindows -o $BIN/bin/xdg-open.exe xdg-open.c

# Fix broken packages
cp /usr/lib/pkgconfig/libxml-2.0.pc $DEV/lib/pkgconfig
rename libxml2.dll libxml2-2.dll {$DEV,$BIN}/bin/*

# Custom settings
mkdir -p $BIN/etc/{gtk-2.0,pango}
cp gtkrc2        $BIN/etc/gtk-2.0/gtkrc
cp pango.aliases $BIN/etc/pango/pango.aliases

# Fix pkg-config
sed -i "s!^prefix=.*!prefix=$DEV!" $DEV/lib/pkgconfig/*.pc
