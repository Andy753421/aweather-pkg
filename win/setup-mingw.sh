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
DEV=/usr/i686-pc-mingw32-2.24
BIN=/scratch/aweather-win32/local/gtk/gtk-2.24

# Copy clean folder
rsync -a /usr/i686-pc-mingw32-clean/ "$DEV/"

# Extract packages
extract -bdx /scratch/aweather/local/extern/gtk+-bundle_2.24.8-20111122_win32.zip
extract -bd  /scratch/aweather/local/extern/iconv-1.9.2.win32.zip
extract -bd  /scratch/aweather/local/extern/libxml2-2.7.6.win32.zip
extract -bx  /scratch/aweather/local/extern/libsoup_2.26.3-1_win32.zip
extract -dx  /scratch/aweather/local/extern/libsoup-dev_2.26.3-1_win32.zip
extract -bx  /scratch/aweather/local/extern/bzip2-1.0.5-bin.zip
extract -dx  /scratch/aweather/local/extern/bzip2-1.0.5-lib.zip

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

i686-pc-mingw32-gcc -Wall -mwindows -o $BIN/bin/xdg-open.exe mingw/xdg-open.c
cp mingw/gtkrc $BIN/etc/gtk-2.0/gtkrc
cp mingw/pango.aliases $BIN/etc/pango/pango.aliases

# Fix pkg-config
sed -i 's!^prefix=.*!prefix=/usr/i686-pc-mingw32!' \
	$DEV/lib/pkgconfig/*.pc

# Install custom programs
#   grits    - DESTDIR=/usr/i686-pc-mingw32 make install
#   rsl      - DESTDIR=/usr/i686-pc-mingw32 make install
#   aweather - DESTDIR=/usr/i686-pc-mingw32 make install
