# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils versionator

SLOT="$(get_major_version)"
RDEPEND=">=virtual/jdk-1.6"

PN1=${PN%-*}
PN2=${PN#*-}
PNS=${PN1:0:1}${PN2:0:1}

MY_ALPHA="$(get_version_component_range 4-4)"
MY_ALPHA=${MY_ALPHA/alpha/}
MY_PRE="$(get_version_component_range 5-5)"
MY_PRE=${MY_PRE/pre/}

RESTRICT="strip"
QA_TEXTRELS="opt/${P}/bin/libbreakgen.so"

DESCRIPTION="IntelliJ IDEA is an intelligent Java IDE"
HOMEPAGE="http://jetbrains.com/idea/"

if [ -z $MY_ALPHA  ]; then
  SRC_URI="http://download.jetbrains.com/${PN1}/${PN1}${PNS^^}-$(get_version_component_range 1-3).tar.gz"
else
  SRC_URI="http://download.jetbrains.com/${PN1}/${PN1}${PNS^^}-${MY_ALPHA}.${MY_PRE}.tar.gz"
fi

LICENSE="IntelliJ-IDEA"
IUSE=""
KEYWORDS="~x86 ~amd64"
S="${WORKDIR}/${PN1}-${PNS}-${MY_BUILD}"

src_prepare() {
    epatch "${FILESDIR}"/idea-run.patch
}

src_install() {
	local dir="/opt/${PN1}${PNS}${SLOT}"
	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}/bin/${PN1}.sh"
	fperms 755 "${dir}/bin/fsnotifier"
	fperms 755 "${dir}/bin/fsnotifier64"
	local exe=${PN1}${PNS}-${SLOT}
	local icon=${exe}.png
	newicon "${S}/bin/${PN1}.png" ${icon}
	dodir /usr/bin
	make_wrapper "$exe" "/opt/${PN1}${PNS}${SLOT}/bin/${PN1}.sh"
	make_desktop_entry ${exe} "IntelliJ IDEA ${PV} ${PN2}" /usr/share/pixmaps/${icon} "Development;IDE"
	insinto /etc/intellij-idea
	doins bin/idea.vmoptions || die
}
