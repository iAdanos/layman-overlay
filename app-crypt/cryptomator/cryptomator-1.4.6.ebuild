# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Free client-side encryption for your cloud files"
HOMEPAGE="https://cryptomator.org/"

SRC_URI="https://dl.bintray.com/${PN}/${PN}/${PV}/${P}-x86_64.AppImage"

SLOT="0"
KEYWORDS="~amd64"
DEPEND="virtual/awk
	sys-apps/grep"
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir -p "${S}" # Without this src_prepare fails
	cp ${DISTDIR}/${A} ./ && chmod a+x ./${A} && ./${A} --appimage-extract || die "Unpacking failed"
}

src_install() {

	S=${WORKDIR}/squashfs-root

	mkdir -p ${D}/opt/${P}
	mkdir -p ${D}/usr/local/bin

	cp -pPR $(ls -d ${S}/* | grep -v "usr") ${D}/opt/${P}
	cp -pPR ${S}/usr ${D}/

	# Update dirs permissions
	find ${D} -type d -exec chmod 755 {} +

	# Update links to /usr
	while read line; do 
		if [[ ! -z "$(grep ^l <<< $line)" ]]; then
			LINK_DEST=$(awk '{ print $NF }' <<< $line)
			LINK_NAME=$(awk '{ print $(NF-2) }' <<< $line)

			if [[ ! -z "$(grep ^usr/ <<< ${LINK_DEST})" ]]; then 
				ln -sf /${LINK_DEST} ${D}/opt/${P}/${LINK_NAME}
			fi
		fi
	done <<< `ls -lah ${D}/opt/${P}`

	ln -sf /opt/${P}/AppRun ${D}/usr/local/bin/${PN}

	insinto / && doins -r / || die

}
