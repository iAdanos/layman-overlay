# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/netatalk/netatalk-2.2.3.ebuild,v 1.2 2012/06/26 04:40:58 zmedico Exp $

EAPI=4

AUTOTOOLS_AUTORECONF=yes

inherit autotools-utils flag-o-matic multilib pam

DESCRIPTION="Open Source AFP server and other AppleTalk-related utilities"
HOMEPAGE="http://netatalk.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="acl avahi cracklib cups debug gpg kerberos ldap pam quota +shadow slp ssl static-libs tcpd"

RDEPEND=">=sys-libs/db-4.2.52
	avahi? ( net-dns/avahi[dbus] )
	cracklib? ( sys-libs/cracklib )
	pam? ( virtual/pam )
	ssl? ( dev-libs/openssl )
	tcpd? ( sys-apps/tcp-wrappers )
	slp? ( net-libs/openslp )
	kerberos? ( virtual/krb5 )
	>=sys-apps/coreutils-7.1
	!app-text/yudit
	dev-libs/libgcrypt
	acl? (
		sys-apps/attr
		sys-apps/acl
	)
	ldap? (
		net-nds/openldap
	)
	"
DEPEND="${RDEPEND}"
RDEPEND="sys-apps/openrc"

RESTRICT="test"

REQUIRED_USE="ldap? ( acl )"

DOCS=( CONTRIBUTORS NEWS VERSION AUTHORS doc/DEVELOPER )

PATCHES=( "${FILESDIR}"/${PN}-3.0-gentoo.patch )

src_prepare() {
	sed \
		-e '/^LDFLAGS/d' \
		-i macros/netatalk.m4 || die
	autotools-utils_src_prepare
}


src_configure() {
	local myeconfargs=()

	if use acl; then
		myconf+=( --with-acls $(use_with ldap) )
	else
		myconf+=( --without-acls --without-ldap )
	fi

	append-flags -fno-strict-aliasing

	# Ignore --with-init-style=gentoo, we install the init.d by hand and we avoid having
	# to sed the Makefiles to not do rc-update.
	# TODO:
	# systemd : --with-init-style=systemd
	myeconfargs+=(
		--disable-silent-rules
		$(use_enable avahi zeroconf)
		$(use_enable debug)
		$(use_enable debug debugging)
		$(use_enable kerberos)
		$(use_enable kerberos krbV-uam)
		$(use_enable quota)
		$(use_enable slp srvloc)
		$(use_enable tcpd tcp-wrappers)
		$(use_with cracklib)
		$(use_with pam)
		$(use_with ssl ssl-dir)
		$(use_with shadow)
		--enable-overwrite
		--disable-krb4-uam
		--disable-afs
		--disable-bundled-libevent
		--enable-fhs
		--with-bdb=/usr
		--with-uams-path=/usr/$(get_libdir)/${PN}
		)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	newinitd "${FILESDIR}"/afpd.init.3 afpd
	newinitd "${FILESDIR}"/cnid_metad.init.2 cnid_metad

	use avahi || sed -i -e '/need avahi-daemon/d' "${D}"/etc/init.d/afpd
	use slp || sed -i -e '/need slpd/d' "${D}"/etc/init.d/afpd

	# The pamd file isn't what we need, use pamd_mimic_system
	rm -rf "${D}/etc/pam.d"
	pamd_mimic_system netatalk auth account password session
}

pkg_postinst() {
	elog "Starting from version 2.2.1-r1 the netatalk init script has been split"
	elog "into different services depending on what you need to start."
	elog "This was done to make sure that all services are started and reported"
	elog "properly."
	elog ""
	elog "The new services are:"
	elog "  cnid_metad"
	elog "  afpd"
	elog "  netatalk"
	elog ""
	elog "Dependencies should be resolved automatically depending on settings"
	elog "but please report issues with this on https://bugs.gentoo.org/ if"
	elog "you find any."
	elog ""
	elog "The old configuration file /etc/netatalk/netatalk.conf is no longer"
	elog "installed, and will be ignored. The new configuration is supposed"
	elog "to be done through individual /etc/conf.d files, for everything that"
	elog "cannot be set already through their respective configuration files."
}
