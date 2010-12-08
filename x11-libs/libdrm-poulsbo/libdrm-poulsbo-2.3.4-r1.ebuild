# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: http://www.freifalt.com - lukas.elsner@freifalt.com $

EAPI="2"

WANT_AUTOMAKE="1.9"

inherit autotools

DESCRIPTION="libdrm for the intel gma500 (poulsbo)"
HOMEPAGE="https://launchpad.net/~gma500/+archive/ppa/+packages"
SRC_URI="http://www.ccube.de/poulsbo/src/libdrm-poulsbo_2.3.4-1ubuntu0sarvatt4~1004um1+karmic.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=">=x11-libs/libdrm-2.3"

S=${WORKDIR}/libdrm-poulsbo-2.3.4

src_unpack() {
	unpack ${A}
}

src_configure() {
	econf --libdir=/usr/lib/psb -includedir=/usr/include/psb
}

src_install() {
	emake install DESTDIR="${D}"
	insinto /usr/include/psb/drm
	doins "${WORKDIR}"/*.h
	dodir /usr/lib/pkgconfig
	mv "${D}/usr/lib/psb/pkgconfig/libdrm.pc" "${D}/usr/lib/pkgconfig/libdrm-poulsbo.pc"
	dodir /etc/env.d
	echo LDPATH=/usr/lib/psb > ${D}/etc/env.d/02psb
}
