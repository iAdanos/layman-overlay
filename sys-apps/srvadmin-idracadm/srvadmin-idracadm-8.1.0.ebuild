# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit rpm

DESCRIPTION="The command line user interface to the Remote Access Controller (RAC)."
HOMEPAGE="http://support.dell.com"

SRC_URI="http://linux.dell.com/repo/hardware/Linux_Repository_15.07.00/platform_independent/rh70_64/srvadmin-x86_64/srvadmin-idracadm-8.1.0-4.4.7.el7.x86_64.rpm"

SLOT="0"
KEYWORDS="~amd64"
DEPEND="app-shells/bash
	dev-libs/argtable
	sys-libs/glibc
	sys-devel/gcc[cxx]
	dev-libs/libpthread-stubs
	dev-libs/openssl
	sys-apps/srvadmin-omilcore"
RDEPEND="${DEPEND}"

src_unpack() {
	rpm_src_unpack ${A}
	mkdir -p "${S}" # Without this src_prepare fails
}

src_install() {
	cp -pPR "${WORKDIR}"/{opt,etc} "${D}"/ || die "Installation failed"

	insinto / && doins -r / || die
}
