# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="ProtonVPN Command-Line Tool for Linux"
HOMEPAGE="https://github.com/ProtonVPN/protonvpn-cli"

SRC_URI="https://github.com/ProtonVPN/${PN}/raw/master/${PN}.sh"

SLOT="0"
KEYWORDS="~amd64"
DEPEND="net-vpn/openvpn
	dev-lang/python
	dev-util/dialog
	net-misc/wget
	sys-process/procps
	sys-apps/coreutils
	virtual/resolvconf"
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir -p "${S}" # Without this src_prepare fails
	return
}

src_install() {
	USER="root"

	mkdir -p "${D}/usr/bin/" "${D}/usr/local/bin/"
	cli="$(cd "$(dirname "${DISTDIR}/${A}")" && pwd -P)/$(basename "${DISTDIR}/${A}")"
	errors_counter=0
	
	cp "$cli" "${D}/usr/local/bin/protonvpn-cli" &> /dev/null
	if [[ $? != 0 ]]; then errors_counter=$((errors_counter+1)); fi

	ln -s -f "${D}/usr/local/bin/protonvpn-cli" "${D}/usr/local/bin/pvpn" &> /dev/null
	if [[ $? != 0 ]]; then errors_counter=$((errors_counter+1)); fi

	ln -s -f "${D}/usr/local/bin/protonvpn-cli" "${D}/usr/bin/protonvpn-cli" &> /dev/null
	if [[ $? != 0 ]]; then errors_counter=$((errors_counter+1)); fi

	ln -s -f "${D}/usr/local/bin/protonvpn-cli" "${D}/usr/bin/pvpn" &> /dev/null
	if [[ $? != 0 ]]; then errors_counter=$((errors_counter+1)); fi

	chown "$USER:$(id -gn $USER)" "${D}/usr/local/bin/protonvpn-cli" "${D}/usr/local/bin/pvpn" "${D}/usr/bin/protonvpn-cli" "${D}/usr/bin/pvpn" &> /dev/null
	if [[ $? != 0 ]]; then errors_counter=$((errors_counter+1)); fi

	chmod 0755 "${D}/usr/local/bin/protonvpn-cli" "${D}/usr/local/bin/pvpn" "${D}/usr/bin/protonvpn-cli" "${D}/usr/bin/pvpn" &> /dev/null
	if [[ $? != 0 ]]; then errors_counter=$((errors_counter+1)); fi

	if [[ ($errors_counter == 0) || ( ! -z $(which protonvpn-cli) ) ]]; then
		true
	else
		die "[!] Error: There was an error in installing protonvpn-cli."
	fi

	insinto / && doins -r / || die
}
