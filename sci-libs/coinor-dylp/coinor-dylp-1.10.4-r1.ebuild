# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=DyLP

inherit flag-o-matic libtool

DESCRIPTION="COIN-OR dynamic simplex linear program solver"
HOMEPAGE="https://github.com/coin-or/DyLP/"
SRC_URI="https://github.com/coin-or/${MY_PN}/archive/releases/${PV}.tar.gz
	-> ${P}.tar.gz"
LICENSE="EPL-1.0"

# major soname component
SLOT="0/1"

KEYWORDS="~amd64 ~loong ~riscv ~x86 ~amd64-linux ~x86-linux"
IUSE="doc examples static-libs test"
RESTRICT="!test? ( test )"

# Fortran is NOT needed, but the ./configure scripts for all of the CoinOR
# packages contain a check for it. Gentoo bug 601648 and upstream issue,
#
#   https://github.com/coin-or/CoinUtils/issues/132
#
BDEPEND="virtual/fortran
	virtual/pkgconfig
	doc? ( app-text/doxygen[dot] )
	test? ( sci-libs/coinor-sample )"

DEPEND="sci-libs/coinor-osi:="
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-releases-${PV}/${MY_PN}"

src_prepare() {
	# Needed to make the --with-coin-instdir in src_configure happy.
	dodir /usr

	# They don't need to guess at this, but they do, and get it wrong...
	sed -e "s:lib/pkgconfig:$(get_libdir)/pkgconfig:g" \
		-i configure \
		|| die "failed to fix the pkgconfig path in ${S}/configure"

	default
	elibtoolize
}

src_configure() {
	# heavily vintage autotools relies on UB to detect SunOS
	# https://bugs.gentoo.org/878143
	# https://github.com/coin-or/DyLP/issues/27
	filter-lto

	local myeconfargs=(
		--enable-dependency-linking
		--with-coin-instdir="${ED}"/usr
		$(use_with doc dot)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake all $(usex doc doxydoc "")
}

src_test() {
	# NOT redundant! The build system has a "make check" target that does
	# nothing, so if you don't specify "test" here, you'll get a no-op.
	emake test
}

src_install() {
	use doc && HTML_DOC=("${BUILD_DIR}/doxydocs/html/")

	emake DESTDIR="${D}" install
	find "${ED}" -type f -name '*.la' -delete || die

	# Duplicate junk, and in the wrong location.
	rm -r "${ED}/usr/share/coin/doc/${MY_PN}" || die

	use examples && dodoc -r examples
}
