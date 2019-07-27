# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SLOT="0"
DESCRIPTION="FSF Emacs compatibility files"
XEMACS_PKG_CAT="standard"

KEYWORDS="alpha amd64 arm64 hppa ppc ppc64 sparc x86 ~amd64-fbsd"

inherit xemacs-packages

RDEPEND="app-xemacs/xemacs-base
"
