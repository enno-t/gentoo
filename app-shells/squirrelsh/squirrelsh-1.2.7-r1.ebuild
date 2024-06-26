# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo flag-o-matic toolchain-funcs

DESCRIPTION="Cross-platform object-oriented scripting shell using the squirrel language"
HOMEPAGE="https://squirrelsh.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}-src.tar.bz2"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="doc"

RDEPEND="dev-libs/libpcre"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-rename-LDFLAGS.patch
	"${FILESDIR}"/${PN}-no-strip.patch
	"${FILESDIR}"/${PN}-fix-in_LDFLAGS.patch
	"${FILESDIR}"/${PN}-remove-forced-abi.patch
	"${FILESDIR}"/${PN}-no-docs.patch
	"${FILESDIR}"/${P}-gcc6.patch
	"${FILESDIR}"/${PN}-drop-register.patch
)

src_configure() {
	# bug #854876
	append-flags -fno-strict-aliasing
	strip-flags

	# This package uses a custom written configure script
	edo ./configure --prefix="${D}"/usr \
		--with-librarian="$(tc-getAR) rc" \
		--with-cc="$(tc-getCC)" \
		--with-cpp="$(tc-getCXX)" \
		--with-linker="$(tc-getCXX)" \
		--libdir=/usr/"$(get_libdir)" \
		--with-pcre="system" \
		--with-squirrel="local" \
		--with-mime=no
}

src_install() {
	emake DESTDIR="${D}" install
	doman doc/${PN}.1
	dodoc HISTORY INSTALL README
	use doc && dodoc doc/*.pdf
}
