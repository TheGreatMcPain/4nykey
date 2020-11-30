# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools pax-utils
if [[ -z ${PV%%*9999} ]]; then
	inherit git-r3
	EGIT_REPO_URI="git://wimlib.net/${PN}"
else
	MY_PV="${PV/_/-}"
	MY_PV="${MY_PV^^}"
	SRC_URI="https://wimlib.net/downloads/${PN}-${MY_PV}.tar.gz -> ${P}.tar.gz"
	RESTRICT="primaryuri"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="The open source Windows Imaging (WIM) library"
HOMEPAGE="https://wimlib.net/"

LICENSE="|| ( GPL-3+ LGPL-3+ ) CC0-1.0"
SLOT="0"
IUSE="cpu_flags_x86_ssse3 fuse ntfs openssl static-libs threads test yasm"
REQUIRED_USE="cpu_flags_x86_ssse3? ( !openssl )"

RDEPEND="
	dev-libs/libxml2:2
	ntfs? ( sys-fs/ntfs3g )
	fuse? ( sys-fs/fuse:0 )
	openssl? ( dev-libs/openssl:0 )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	cpu_flags_x86_ssse3? (
		yasm? ( dev-lang/yasm )
		!yasm? ( dev-lang/nasm )
	)
"
PATCHES=( "${FILESDIR}"/${PN}-tests.diff )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_with ntfs ntfs-3g)
		$(use_with fuse)
		$(use_enable cpu_flags_x86_ssse3 ssse3-sha1)
		$(use_with openssl libcrypto)
		$(use_enable threads multithreaded-compression)
		$(use_enable static-libs static)
	)
	use test && myeconfargs+=( --enable-test-support )
	ac_cv_prog_NASM="$(usex yasm yasm nasm)" \
		econf "${myeconfargs[@]}"
}

src_compile() {
	emake
	pax-mark m "${S}"/.libs/wimlib-imagex
}

src_install() {
	default
	find "${ED}" -type f -name '*.la' -delete
}
