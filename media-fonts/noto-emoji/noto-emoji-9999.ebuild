# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )
inherit python-any-r1 font-r1
if [[ -z ${PV%%*9999} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/googlefonts/${PN}"
else
	MY_PV="v${PV}"
	[[ -z ${PV%%*_p*} ]] && MY_PV="ac1703e"
	MY_P="${PN}-${MY_PV#v}"
	SRC_URI="
		mirror://githubcl/googlefonts/${PN}/tar.gz/${MY_PV}
		-> ${MY_P}.tar.gz
	"
	RESTRICT="primaryuri"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi

DESCRIPTION="Noto Emoji fonts"
HOMEPAGE="https://github.com/googlefonts/${PN}"

LICENSE="OFL-1.1"
SLOT="0"
IUSE="+binary"

BDEPEND="
!binary? (
	${PYTHON_DEPS}
	$(python_gen_any_dep '
		>=dev-python/nototools-0.2.16[${PYTHON_USEDEP}]
	')
	media-gfx/pngquant
	virtual/imagemagick-tools[png]
	app-arch/zopfli
	x11-libs/cairo
	>=app-i18n/unicode-emoji-14.0
)
"
PATCHES=( "${FILESDIR}"/${PN}-makefile.diff )

pkg_setup() {
	if use binary; then
		FONT_S=( fonts )
	else
		python-any-r1_pkg_setup
	fi
	font-r1_pkg_setup
}

src_prepare() {
	default
	rm -f fonts/NotoColorEmoji_WindowsCompatible.ttf
	use binary && return
	sed \
		-e 's:^\t@:\t:' \
		-e '/\(C\|LD\)FLAGS =/s:=:+=:' \
		-e 's:\<pkg-config\>:$(PKG_CONFIG):' \
		-e 's: \$(EMOJI_WINDOWS).ttf::' \
		-i Makefile
}

src_compile() {
	use binary && return
	tc-env_build emake \
		PNGQUANT=/usr/bin/pngquant \
		PYTHON="${EPYTHON}" \
		VIRTUAL_ENV=1
	rm -f *.tmpl.ttf
}
