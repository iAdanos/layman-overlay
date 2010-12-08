# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: http://www.freifalt.com - lukas.elsner@freifalt.com $

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

S="${WORKDIR}/${PN}"

src_install() {

	insopts -m0755

	insinto /usr/lib/dri
	doins dri/psb_dri.so

	insinto /usr/lib/va/drivers
	doins dri/psb_drv_video.la
	doins dri/psb_drv_video.so

	insinto /usr/lib/xorg/modules/drivers
	doins drivers/Xpsb.la
	doins drivers/Xpsb.so
}
