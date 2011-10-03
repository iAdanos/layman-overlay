# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-news/liferea/liferea-1.7.4.ebuild,v 1.6 2011/03/21 22:19:52 nirbheek Exp $

EAPI=2

GCONF_DEBUG=no

inherit eutils git

MY_P=${P/_/-}

DESCRIPTION="Filemanager"
HOMEPAGE="http://code.jollybox.de/emperor.xhtml"
EGIT_REPO_URI="git://github.com/tjol/emperor.git"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="libnotify"

RDEPEND=">=x11-libs/gtk+-3.0.0
	>=dev-libs/libxml2-2.6.27:2
	libnotify? ( >=x11-libs/libnotify-0.7 )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig"

DOCS=""

S=${WORKDIR}/${MY_P}

#pkg_setup() {
#}

src_prepare() {
	./bootstrap.sh
}

#src_install() {
#}
