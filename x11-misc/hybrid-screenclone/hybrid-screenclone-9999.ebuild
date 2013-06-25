# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit git-2

DESCRIPTION="A reimplementation of hybrid-windump with the opposite use-case:
doing all rendering using the integrated intel card and using the additional
card just to get more outputs"
HOMEPAGE="https://github.com/liskin/hybrid-screenclone"
SRC_URI=""
EGIT_REPO_URI="git://github.com/liskin/hybrid-screenclone.git
	https://github.com/liskin/hybrid-screenclone.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-libs/libX11
	x11-libs/libXtst"
RDEPEND="${DEPEND}"

src_install() {
	dobin screenclone
	insinto /etc/X11/
	doins xorg.conf.nvidia
	dodoc README.markdown
	dodoc screenclone-runx.sample
}
