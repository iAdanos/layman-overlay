# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/netatalk/netatalk-2.2.2.ebuild,v 1.1 2012/05/02 17:13:24 jlec Exp $

EAPI="4"

inherit pam flag-o-matic multilib autotools


#S="${WORKDIR}/${PV}"

RESTRICT="test"
DESCRIPTION="Open Source AFP server"
HOMEPAGE="http://netatalk.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="acl avahi cracklib cups debug kerberos ldap pam quota ssl tcpd no-bundled-libevent"

RDEPEND=">=sys-libs/db-4.2.52
	avahi? ( net-dns/avahi[dbus] )
	cracklib? ( sys-libs/cracklib )
	pam? ( virtual/pam )
	ssl? ( dev-libs/openssl )
	tcpd? ( sys-apps/tcp-wrappers )
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

REQUIRED_USE="ldap? ( acl )"

DOCS=( CONTRIBUTORS NEWS VERSION AUTHORS )

src_prepare() {
	epatch "${FILESDIR}"/${P}-ldconfig-fix.patch
	eautoreconf
}

src_configure() {
	local myconf=

	if use acl; then
		myconf+=" --with-acls $(use_with ldap)"
	else
		myconf+=" --without-acls --without-ldap"
	fi

	if use no-bundled-libevent; then
		myconf+=" --disable-bundled-libevent"
	fi


	append-flags -fno-strict-aliasing

	econf \
		$(use_enable avahi zeroconf) \
		$(use_enable debug) \
		$(use_enable kerberos krbV-uam) \
		$(use_enable quota) \
		$(use_enable tcpd tcp-wrappers) \
		$(use_with cracklib) \
		$(use_with pam) \
		$(use_with ssl ssl-dir) \
		--disable-krb4-uam \
		--disable-afs \
		--enable-fhs \
		--with-bdb=/usr \
		${myconf}
}

src_install() {
	default
	newinitd "${FILESDIR}"/netatalk.init netatalk

	# The pamd file isn't what we need, use pamd_mimic_system
	rm -rf "${D}etc/pam.d"
	pamd_mimic_system netatalk auth account password session

		# These are not used at all, as the uams are loaded with their .so
	# extension.
	#
	#rm "${D}"/usr/$(get_libdir)/netatalk/*.la

	mv "${D}"lib/* "${D}"usr/lib64
}
