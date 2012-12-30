1. Install XCode and XCode command line tools

2. Install jhbuild:

   $ sh gtk-osx-build-setup.sh

3. Install gtk+ and dependencies

   $ jhbuild bootstrap
   $ jhbuild build meta-gtk-osx-bootstrap
   $ jhbuild build meta-gtk-osx-gtk3
   $ jhbuild build gtk-mac-integration
   $ jhbuild build libsoup

   $ jhbuild build meta-gtk-osx-themes   ??? doens't build, gtk2 dep

   $ jhbuild build librsvg               ??? for gtk-css-engine
   $ jhbuild build libccss               ??? for gtk-css-engine
   $ jhbuild build gtk-css-engine        ??? doesn't build, gtk2 dep

   $ jhbuild build gnome-themes-standard ??? after copying into gtk-osx.modules, and editing..

4. Instlal gtk-mac-bundler

   $ git://git.gnome.org/gtk-mac-bundler
   $ make install

5. Install create-dmg

   ???

References:

   https://live.gnome.org/GTK+/OSX/Building
