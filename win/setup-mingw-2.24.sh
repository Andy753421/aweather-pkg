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

# Install locations
MINGW=i486-mingw32
DEV=/usr/$MINGW/usr
BIN=/scratch/aweather-win32/local/gtk/gtk-2.24
EXT=/home/andy/b/scratch/aweather/local/extern

# Copy clean folder
rsync -a /usr/$MINGW-clean/ "$DEV/"

# Extract packages
extract -bdx $EXT/gtk+-bundle_2.24.8-20111122_win32.zip
extract -bd  $EXT/iconv-1.9.2.win32.zip
extract -bd  $EXT/libxml2-2.7.6.win32.zip
extract -bx  $EXT/libsoup_2.26.3-1_win32.zip
extract -dx  $EXT/libsoup-dev_2.26.3-1_win32.zip
extract -bx  $EXT/bzip2-1.0.5-bin.zip
extract -dx  $EXT/bzip2-1.0.5-lib.zip
extract -dx  $EXT/freeglut-MinGW-2.8.0-1.mp.zip

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

# Fix broken packages
cp /usr/lib/pkgconfig/libxml-2.0.pc $DEV/lib/pkgconfig
rename libxml2.dll libxml2-2.dll {$DEV,$BIN}/bin/*

$MINGW-gcc -Wall -mwindows -o $BIN/bin/xdg-open.exe xdg-open.c
cp gtkrc $BIN/etc/gtk-2.0/gtkrc
cp pango.aliases $BIN/etc/pango/pango.aliases

# Fix pkg-config
sed -i 's!^prefix=.*!prefix=/usr/'$MINGW'/usr!' \
	$DEV/lib/pkgconfig/*.pc

# Install custom programs
#   grits    - DESTDIR=/usr/$MINGW make install
#   rsl      - DESTDIR=/usr/$MINGW make install
#   aweather - DESTDIR=/usr/$MINGW make install