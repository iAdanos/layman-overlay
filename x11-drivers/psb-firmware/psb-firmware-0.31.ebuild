# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: http://www.freifalt.com - lukas.elsner@freifalt.com $


DESCRIPTION="firmware for the intel gma500 (poulsbo)"
HOMEPAGE="https://launchpad.net/~gma500/+archive/ppa/+packages"
SRC_URI="http://www.ccube.de/poulsbo/src/psb-firmware_0.31-0ubuntu1~910um1.tar.gz"

LICENSE="intel-psb"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
}

src_install() {
	cd "${WORKDIR}/${PN}"
	insinto /lib/firmware
	doins msvdx_fw.bin
}
