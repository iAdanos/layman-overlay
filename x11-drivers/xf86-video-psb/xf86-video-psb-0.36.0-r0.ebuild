# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: http://www.freifalt.com - lukas.elsner@freifalt.com $

EAPI="2"

inherit autotools flag-o-matic

DESCRIPTION="xorg driver for the intel gma500 (poulsbo)"
HOMEPAGE="https://launchpad.net/~gma500/+archive/ppa/+packages"
SRC_URI="http://www.ccube.de/poulsbo/src/xserver-xorg-video-psb_0.36.0-0ubuntu3~1104um1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="x11-base/xorg-server
	x11-proto/xf86dgaproto
	x11-proto/randrproto
	x11-proto/xf86driproto
	x11-proto/xineramaproto
	x11-libs/libdrm-poulsbo"
RDEPEND="$DEPEND
	x11-drivers/psb-kmod
	x11-libs/xpsb-glx"

S=${WORKDIR}/xserver-xorg-video-psb

src_prepare() {
	epatch "${FILESDIR}/xorg-x11-drv-psb-0.31.0-ignoreacpi.patch"
	epatch "${FILESDIR}/xorg-x11-drv-psb-0.31.0-xserver17.patch"
	epatch "${FILESDIR}/xserver-xorg-video-psb-0.31.0-assert.patch"
	epatch "${FILESDIR}/xserver-xorg-video-psb-0.31.0-comment_unused.patch"
	epatch "${FILESDIR}/xserver-xorg-video-psb-0.31.0-greedy.patch"
	epatch "${FILESDIR}/xserver-xorg-video-psb-0.31.0-loader.patch"
	epatch "${FILESDIR}/stubs.patch"
	epatch "${FILESDIR}/01_disable_lid_timer.patch"
	epatch "${FILESDIR}/psb_xvtempfix.patch"
	epatch "${FILESDIR}/psb_mixed.patch"
	epatch "${FILESDIR}/HDMI-fix.patch"
	epatch "${FILESDIR}/root-gc.patch"
	epatch "${FILESDIR}/xorg-x11-drv-psb-0.32.0-mibank.patch"
	epatch "${FILESDIR}/xorg-x11-drv-psb-0.32.0-symbols.patch"
	epatch "${FILESDIR}/xorg-x11-drv-psb-0.32.0-null.patch"
	eautoreconf
}

src_configure() {
	append-flags -fvisibility=default
	econf
}

src_compile() {
	emake
}

src_install() {
	emake install DESTDIR="${D}" || die "Make failed"
}
