#!/bin/bash
#
# from: https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/


cat <<HERE
add this to your .bashrc/.zshrc, if it doesn't already exist, before the DAVINCI_* env vars:

  export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"
  export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

HERE

#brew tap homebrew/dupes
#brew install coreutils
#brew install binutils
#brew install diffutils
#brew install ed --with-default-names
#brew install findutils --with-default-names
#brew install gawk
#brew install gnu-indent --with-default-names
#brew install gnu-sed --with-default-names
#brew install gnu-tar --with-default-names
#brew install gnu-which --with-default-names
#brew install gnutls
#brew install grep --with-default-names
#brew install gzip
#brew install screen
#brew install watch
#brew install wdiff --with-gettext
#brew install wget
#brew install bash

#xcode-select --install
