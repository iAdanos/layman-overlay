# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="DSL Modem Tool - read line characteristics and generate statistics"
HOMEPAGE="http://www.spida.net/projects/software/dmt-ux"
SRC_URI="http://www.spida.net/projects/software/dmt-ux/dmt-ux-${PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="png rrdtool"

RDEPEND="png? ( media-fonts/ttf-bitstream-vera )"
DEPEND="png? ( media-libs/libpng
             >=media-libs/freetype-2.0.0 )
             rrdtool? ( >=net-analyzer/rrdtool-1.2.0 )"

src_unpack() {
	unpack ${A}
	cd ${S}
	use rrdtool || sed -i -e 's:-lrrd::g' \
	-e 's:rrdstat.o::' -e 's:-Drrd::' Makefile
	use png || sed -i -e 's:-lpng::g' -e 's:-lfreetype::' \
	-e 's:graphic.o::' -e 's:-Dgraphic::'\
	-e 's:-I/usr/local/include/freetype2::' \
	-e 's:-I/usr/include/freetype2::' Makefile
	sed -i -e \
	's:./fonts/Vera.ttf:/usr/share/fonts/ttf-bitstream-vera/Vera.ttf:' dmt-ux.c
}

src_install() {
	dobin dmt-ux
	dodoc doc/README 
}



