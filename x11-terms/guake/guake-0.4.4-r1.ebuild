# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/guake/guake-0.4.3.ebuild,v 1.2 2012/06/26 19:40:50 lu_zero Exp $

EAPI=4

GCONF_DEBUG=no
GNOME2_LA_PUNT=yes
PYTHON_DEPEND="2:2.7"

inherit gnome2 python

DESCRIPTION="A dropdown terminal made for the GTK+ desktops"
HOMEPAGE="http://guake.org/"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV}.orig.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND="dev-python/dbus-python
	dev-python/gconf-python
	dev-python/notify-python
	dev-python/pygtk
	dev-python/pyxdg
	gnome-base/gconf
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/vte:0[python]"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	G2CONF="--disable-static"
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/guake-0.4.3-fix-window-height-settings.patch
	epatch "${FILESDIR}"/guake-0.4.3-slide-from-bottom-or-top.patch

	epatch "${FILESDIR}"/0001-Added-a-checkbox-in-the-preferences-dialog-that-lets.patch
	epatch "${FILESDIR}"/0001-Added-starting-in-fullscreen-mode-with-a-prefs-check.patch
	epatch "${FILESDIR}"/0001-Add-monitor-choice-to-UI.patch
	epatch "${FILESDIR}"/0001-Quick-Google-search-from-context-menu.patch
	epatch "${FILESDIR}"/0002-Added-start-in-fullscreen-to-the-gconf-schema.patch
	epatch "${FILESDIR}"/arrow-scroll.patch
	epatch "${FILESDIR}"/fix_ctrl_global.patch
	epatch "${FILESDIR}"/fix-font-size-guake.py.patch
	epatch "${FILESDIR}"/fix-font-size-guake.schemas.patch
	epatch "${FILESDIR}"/fix-font-size-prefs.py.patch
	epatch "${FILESDIR}"/guake-230-top-panel.patch
	epatch "${FILESDIR}"/guake-fix-pref.desktop.patch
	epatch "${FILESDIR}"/guake.glade.patch

	epatch_user
	
	python_convert_shebangs 2 src/{guake,prefs.py}

	# We byte-compile in pkg_postinst()
	>py-compile

	gnome2_src_prepare
}

pkg_postinst() {
	gnome2_pkg_postinst
	python_mod_optimize ${PN}
}

pkg_postrm() {
	gnome2_pkg_postrm
	python_mod_cleanup ${PN}
}
