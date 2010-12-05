# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xpsb-glx/xpsb-glx-0.18_p4.ebuild,v 1.1 2009/09/13 20:09:12 patrick Exp $

EAPI="2"


DESCRIPTION="glx for the intel gma500 (poulsbo)"
HOMEPAGE="https://launchpad.net/~gma500/+archive/ppa/+packages"
SRC_URI="http://www.ccube.de/poulsbo/src/xpsb-glx_0.19-0ubuntu2~1104um1.tar.gz"


LICENSE="intel-psb"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}/mesa"

src_prepare() {
	eautoreconf
}
src_configure() {
	econf
}

src_compile() {
	emake
}

src_install() {

	emake install DESTDIR="${D}" || die "Make failed"

	insopts -m0755

	insinto /usr/lib/dri
	doins ../dri/psb_dri.so

	insinto /usr/lib/va/drivers
	doins ../dri/psb_drv_video.la
	doins ../dri/psb_drv_video.so

	insinto /usr/lib/xorg/modules/drivers
	doins ../drivers/Xpsb.la
	doins drivers/Xpsb.so
}
