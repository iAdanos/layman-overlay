# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/xbmc/xbmc-9999.ebuild,v 1.121 2012/10/09 21:44:28 vapier Exp $

EAPI="4"

inherit eutils git-2 autotools
EGIT_REPO_URI="git://github.com/opdenkamp/xbmc-pvr-addons.git"

DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/"

LICENSE="GPL-2"
SLOT="0"
COMMON_DEPEND="media-tv/xbmc"

src_unpack() {
	git-2_src_unpack
	cd "${S}"
	rm -f configure
}

src_prepare() {
	eautoreconf
	epatch_user #293109
	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure
}

src_configure() {
	econf
}

src_install() {
	default
}
