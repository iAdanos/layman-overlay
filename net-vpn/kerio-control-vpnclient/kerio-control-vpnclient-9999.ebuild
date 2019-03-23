# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Kerio Control VPN Client
 Internet access management for corporate networks."
HOMEPAGE="https://www.kerio.com/"
LICENSE="no-source-code"

MAIN_INSTALLER_STRING="http://download.kerio.com/eu/dwn/${PN}-linux"
CFGFILE="${ROOT}/etc/kerio-kvc.conf"
SERVICE_NAME="kerio-kvc"

SRC_URI="
	x86?      ( ${MAIN_INSTALLER_STRING}.deb )
	amd64?    ( ${MAIN_INSTALLER_STRING}-amd64.deb )"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="systemd libuuid"
DEPEND="sys-devel/binutils
	sys-apps/grep
	app-shells/bash
	sys-libs/glibc
	sys-devel/gcc[cxx]
	libuuid? ( sys-libs/libuuid ) : ( sys-apps/util-linux )
	sys-process/procps
	dev-libs/openssl"
RDEPEND="${DEPEND}"

src_unpack() {
	pwd
	find ../
	ar x ${DISTDIR}/${A}
	for ARCHIVE in $(ls | grep \.tar); do 
		mkdir ${ARCHIVE%%.*}
		cd ${ARCHIVE%%.*}
		unpack ../${ARCHIVE}
		cd ../
	done
	mkdir -p "${S}" # Without this src_prepare fails
}

src_install() {

	S=${WORKDIR}/data

	into /usr
	dolib.so ${S}/usr/lib/*

	exeinto /usr/sbin
	doexe ${S}/usr/sbin/*

	insinto /usr/share
	doins -r ${S}/usr/share/lintian

	docinto /
	dodoc ${S}/usr/share/doc/${PN}/*

	dodir /lib/systemd
	insinto /lib/systemd
	doins -r ${S}/lib/systemd/system-generators

	if use systemd; then
		doins -r ${S}/lib/systemd/system
	else
		insinto /etc/init.d
		doins ${S}/etc/init.d/${SERVICE_NAME}
	fi
	
}

pkg_postinst() {

	. ${ROOT}/lib/systemd/system-generators/kerio-kvc.generator

	cat > "$CFGFILE" << EOF
<config>
  <connections>
    <connection type="persistent">
      <server>SERVER_ADDRESS</server>
      <port>PORT</port>
      <username>USERNAME</username>
      <password>XOR:\$(PASSWORD="YOUR PASSWORD"; for i in \`echo -n "\$PASSWORD" | od -t d1 -A n\`; do XOR=\$(printf "%s%02x" "\$XOR" \$((i ^ 85))); done; echo \${XOR})</password>
      <fingerprint>\$(echo | openssl s_client -connect SERVER_ADDRESS:PORT | openssl x509 -fingerprint -md5 -noout | sed s'/.*=//')</fingerprint>
      <active>1</active>
    </connection>
  </connections>
</config>
EOF

	chmod 0600 "$CFGFILE"
	LDCONFIG_NOTRIGGER=y ldconfig

	pkg_info
}

pkg_info() {
	elog "To configure Kerio Control VPN Client edit"
	elog "* ${CFGFILE}"
	elog " "
	elog "To automatically start ${SERVICE_NAME} run"
	if use systemd; then
		elog "systemctl enable --now ${SERVICE_NAME}.service"
	else 
		elog "rc-config add ${SERVICE_NAME}"
		elog "rc-config start ${SERVICE_NAME}"
	fi
	elog " "
	elog "Encode password (to XOR) to put in ${CFGFILE}:"
	elog "echo \$(PASSWORD=\"YOUR PASSWORD\"; for i in \`echo -n \"\$PASSWORD\" | od -t d1 -A n\`; do XOR=\$(printf \"%s%02x\" \"\$XOR\" \$((i ^ 85))); done; echo \${XOR})"
	elog " "
	elog "Get server fingerprint to put in ${CFGFILE}:"
	elog "echo \"Server fingerprint: \$(echo | openssl s_client -connect SERVER_ADDRESS:PORT | openssl x509 -fingerprint -md5 -noout | sed s'/.*=//')\""
}

pkg_prerm() {
	if use systemd; then
		systemctl stop ${SERVICE_NAME} || exit $?
	else
		rc-config stop ${SERVICE_NAME} || exit $?
	fi
}

pkg_postrm() {
	ldconfig
	if use systemd ; then
		systemctl --system daemon-reload >/dev/null || true
	else
		rc-config delete ${SERVICE_NAME} >/dev/null || true
	fi
}
