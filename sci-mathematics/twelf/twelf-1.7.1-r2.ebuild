# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

inherit elisp-common flag-o-matic

MY_PN="${PN}-src"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Implementation of the logical framework LF"
HOMEPAGE="https://twelf.org/"
SRC_URI="https://github.com/standardml/twelf/releases/download/v${PV}/${MY_P}.tar.gz"

SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
LICENSE="BSD-2"
IUSE="doc emacs examples"

# tests reference non-existing directory TEST
RESTRICT="test"

RDEPEND="
	>=dev-lang/mlton-20180207
	doc? (
		virtual/latex-base
		app-text/texi2html
	)
	emacs? (
		>=app-editors/emacs-23.1:*
	)"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}

SITEFILE=50${PN}-gentoo.el

PATCHES=(
	"${FILESDIR}"/${PN}-1.7.1-doc-guide-twelf-dot-texi.patch
	"${FILESDIR}"/${PN}-1.7.1-doc-guide-Makefile.patch
	"${FILESDIR}"/${PN}-1.7.1-emacs-twelf.patch
	"${FILESDIR}"/${PN}-1.7.1-emacs-twelf-init.patch
	"${FILESDIR}"/${PN}-1.7.1-Makefile.patch
	"${FILESDIR}"/${PN}-1.7.1-mlton-mlb.patch
	"${FILESDIR}"/${PN}-1.7.1-mlton-20180207.patch
	"${FILESDIR}"/${PN}-1.7.1-remove-svnversion.patch                 # 728028
	"${FILESDIR}"/${PN}-1.7.1-emacs-fix-old-style-backquotes-p1.patch # 803296
	"${FILESDIR}"/${PN}-1.7.1-emacs-fix-old-style-backquotes-p2.patch
	"${FILESDIR}"/${PN}-1.7.1-emacs-fix-old-style-backquotes-p3.patch
)

src_prepare() {
	default
	sed \
		-e "s@/usr/bin@${PREFIX}/usr/bin@g" \
		-e "s@/usr/share@${PREFIIX}/usr/share@" \
		-i "${S}"/emacs/twelf-init.el \
		|| die "Could not set PREFIX in ${S}/emacs/twelf-init.el"
}

src_compile() {
	# relocation R_X86_64_32 against hidden symbol `globalCPointer' can not be used when making a PIE object
	# https://bugs.gentoo.org/863266
	#
	# The software is unmaintained and disables bug reports.
	filter-lto

	emake mlton CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -fno-PIE"
	if use emacs ; then
		pushd "${S}/emacs" || die "Could change directory to emacs"
		elisp-compile \
			auc-menu.el \
			twelf-font.el \
			twelf-init.el \
			twelf.el \
			|| die "emacs elisp compile failed"
		popd
	fi
	if use doc; then
		pushd doc/guide
		emake -j1
		popd
	fi
}

ins_example_dir() {
	insinto "/usr/share/${PN}/examples/${1}"
	pushd "${S}/${1}"
	doins -r *
	popd
}

src_install() {
	if use emacs ; then
		elisp-install ${PN} emacs/*.{el,elc}
		cp "${FILESDIR}"/${SITEFILE} "${S}"
		elisp-site-file-install ${SITEFILE}
	fi
	if use examples; then
		ins_example_dir examples
		ins_example_dir examples-clp
		ins_example_dir examples-delphin
	fi
	dobin bin/twelf-server
	if use doc; then
		local DOCS=( doc/guide/twelf.dvi doc/guide/twelf.ps doc/guide/twelf.pdf )
		local HTML_DOCS=( doc/html/index.html doc/guide/twelf/. )
		doinfo doc/guide/twelf.info
		einstalldocs
	fi
}

pkg_postinst() {
	if use emacs; then
		elisp-site-regen
		ewarn "For twelf emacs, add this line to ~/.emacs"
		ewarn ""
		ewarn '(load (concat twelf-root "/twelf-init.el"))'
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
