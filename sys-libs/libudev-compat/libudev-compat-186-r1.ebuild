# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal toolchain-funcs

DESCRIPTION="Wrapper around libudev.so.1 for packages needing the old libudev.so.0"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="virtual/libudev:0/1[${MULTILIB_USEDEP}]"
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir "${S}" || die
	cp "${FILESDIR}"/udev_old.c "${S}" || die
}

multilib_src_configure() { :; }

echo_and_run() {
	echo "$@"
	"$@"
}

multilib_src_compile() {
	# Note: --no-as-needed is used explictly here to ensure that libudev.so.1
	# is pulled in, even though nothing in udev_old.c otherwise requires it
	echo_and_run $(tc-getCC) \
		${CFLAGS} ${CPPFLAGS} ${LDFLAGS} \
		-fpic -shared \
		-Wl,-soname,libudev.so.0 \
		-o libudev.so.0 \
		"${S}"/udev_old.c \
		-Wl,--no-as-needed \
		-ludev || die
}

multilib_src_install() {
	dolib.so libudev.so.0
}
