# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit gnome2-utils
if [[ -z ${PV%%*9999} ]]; then
	inherit mercurial
	EHG_REPO_URI="https://bitbucket.org/mathematicalcoffee/${PN}-gnome-shell-extension"
	SRC_URI=""
else
	inherit vcs-snapshot
	KEYWORDS="~amd64 ~x86"
	SRC_URI="
		https://bitbucket.org/mathematicalcoffee/${PN}-gnome-shell-extension/get/6774bac.tar.gz
		-> ${P}.tar.gz
	"
fi

DESCRIPTION="A GNOME shell extension to reduce the horizontal spacing between status area icons"
HOMEPAGE="https://bitbucket.org/mathematicalcoffee/status-area-horizontal-spacing-gnome-shell-extension"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="
	app-eselect/eselect-gnome-shell-extensions
"
RDEPEND="
	${DEPEND}
"

src_prepare() {
	cd ${PN}@mathematical.coffee.gmail.com
	sed -e 's:"3.16":&, "3.18":' -i metadata.json
	mv schemas ..
}

src_compile() { :; }

src_install() {
	insinto /usr/share/gnome-shell/extensions
	doins -r ${PN}@mathematical.coffee.gmail.com
	insinto /usr/share/glib-2.0/schemas
	doins schemas/*.xml
	dodoc Readme*
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update

	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
	elog
	elog "Installed extensions installed are initially disabled by default."
	elog "To change the system default and enable some extensions, you can use"
	elog "# eselect gnome-shell-extensions"
	elog "Alternatively, to enable/disable extensions on a per-user basis,"
	elog "you can use the https://extensions.gnome.org/ web interface, the"
	elog "gnome-extra/gnome-tweak-tool GUI, or modify the org.gnome.shell"
	elog "enabled-extensions gsettings key from the command line or a script."
	elog
}

pkg_postrm() {
	gnome2_schemas_update
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
