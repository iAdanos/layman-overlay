# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils versionator

SLOT="$(get_major_version)"
RDEPEND=">=virtual/jdk-1.6"

MY_PV="$(get_version_component_range 4-5)"
MY_PN="idea-community"

RESTRICT="strip"
QA_TEXTRELS="opt/${P}/bin/libbreakgen.so"

DESCRIPTION="IntelliJ IDEA is an intelligent Java IDE"
HOMEPAGE="http://jetbrains.com/idea/"
SRC_URI="http://download.jetbrains.com/idea/ideaIC-$(get_version_component_range 1-3).tar.gz"
LICENSE="IntelliJ-IDEA"
IUSE=""
KEYWORDS="~x86 ~amd64"
S="${WORKDIR}/${MY_PN}-IC-${MY_PV}"

src_install() {
	local dir="/opt/${MY_PN}"
	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}/bin/${MY_PN}.sh"
	local exe=${MY_PN}-${SLOT}
	local icon=${exe}.png
	newicon "bin/${MY_PN}_CE32.png" ${icon}
	dodir /usr/bin
	make_wrapper "$exe" "/opt/${P}/bin/${MY_PN}.sh"
	make_desktop_entry ${exe} "IntelliJ IDEA ${PV}" ${icon} "Development;IDE"
}