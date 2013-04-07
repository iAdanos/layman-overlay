	# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

CMAKE_IN_SOURCE_BUILD="1"
inherit cmake-utils linux-info versionator

#MY_PV=$(replace_version_separator 3 '-' ${PV/rc})
#MY_PV=$(replace_version_separator 4 '-' ${MY_PV})
#MY_P=${PN}-${MY_PV}

DESCRIPTION="Shrew soft VPN Client"
HOMEPAGE="http://www.shrew.net/"
#SRC_URI="http://www.shrew.net/download/${PN}/${MY_P}.tbz2"
SRC_URI="https://www.shrew.net/download/ike/ike-2.2.0-rc-3.tbz2"

LICENSE="shrew"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ldap nat qt4"

COMMON_DEPEND="dev-libs/libedit
	dev-libs/openssl
	qt4? ( x11-libs/qtcore )
	ldap? ( net-nds/openldap )"
DEPEND="${COMMON_DEPEND}
	dev-util/cmake
	>=sys-devel/bison-2.3
	sys-devel/flex"
RDEPEND="${COMMON_DEPEND}"

DOCS="CONTRIB.TXT README.TXT TODO.TXT"

CONFIG_CHECK="INET_XFRM_MODE_TRANSPORT INET_XFRM_MODE_TUNNEL"

S="${WORKDIR}/${PN}"

src_configure(){
	mycmakeargs+=( $(cmake-utils_use ldap LDAP)
		$(cmake-utils_use nat NATT)
		$(cmake-utils_use qt4 QTGUI)
		"-DMANDIR=/usr/share/man")

	cmake-utils_src_configure
}

src_install(){
	cmake-utils_src_install
	doinitd ${FILESDIR}/iked || die
}
