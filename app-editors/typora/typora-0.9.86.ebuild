# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="A minimal Markdown reading & writing app"
HOMEPAGE="https://typora.io/"

SRC_URI="https://typora.io/linux/${PN}_${PV}_amd64.deb"

SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	ar x ${DISTDIR}/${A}
    unpack ./data.tar.xz
	mkdir -p "${S}" # Without this src_prepare fails
}

src_install() {
	cp -pPR "${WORKDIR}"/usr "${D}"/ || die "Installation failed"
	insinto / && doins -r / || die
}
