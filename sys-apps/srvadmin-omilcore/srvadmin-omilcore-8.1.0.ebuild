# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit rpm

DESCRIPTION="This is the core install package that provides the tools necessary for the rest of the Systems Management install packages"
HOMEPAGE="http://support.dell.com"

SRC_URI="http://linux.dell.com/repo/hardware/Linux_Repository_15.07.00/platform_independent/rh70_64/srvadmin-x86_64/srvadmin-omilcore-8.1.0-4.85.1.el7.x86_64.rpm"

SLOT="0"
KEYWORDS="~amd64"
DEPEND="app-shells/bash
	dev-lang/python
	sys-apps/pciutils
	sys-libs/libsmbios"
RDEPEND="${DEPEND}"

src_unpack() {
	rpm_src_unpack ${A}
	mkdir -p "${S}" # Without this src_prepare fails
}

src_install() {
	cp -pPR "${WORKDIR}"/{opt,etc} "${D}"/ || die "Installation failed"

	insinto / && doins -r / || die
}
