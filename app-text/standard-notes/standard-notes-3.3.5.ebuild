# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="A free, open-source, and completely encrypted notes app"
HOMEPAGE="https://standardnotes.org/"

MAIN_INSTALLER_STRING="https://github.com/standardnotes/desktop/releases/download/v${PV}/Standard-Notes-${PV}"

SRC_URI="
	amd64?    ( ${MAIN_INSTALLER_STRING}.AppImage )"

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

	mkdir -p ${D}/opt/${PN}
	mkdir -p ${D}/usr/local/bin
	mkdir -p ${D}/usr/share/applications/

	into /usr/lib
	for LIBRARY_FILE in $(find ${S}/usr/lib/*); do
	  if [[ ! -f "/usr/lib/$(echo ${LIBRARY_FILE} | awk -F '/usr/lib/' '{ print $2 }')" ]]; then
	    echo $LIBRARY_FILE 1>&2
	  	dolib.so ${LIBRARY_FILE}
	  fi
	done
	

	insinto /usr
	doins -r ${S}/usr/share

	for DESKTOP_LINK in $(find ${S} -name '*.desktop'); do
	  cat ${DESKTOP_LINK} | sed "s/AppRun/${PN}/" > ${DESKTOP_LINK}_edited
	  mv ${DESKTOP_LINK}_edited ${DESKTOP_LINK}
	  ln -s /opt/${PN}/$(echo ${DESKTOP_LINK} | awk -F "${S}/" '{ print $2 }' ) ${D}/usr/share/applications/$(basename ${DESKTOP_LINK})
	done

	cp -pPR $(ls -d ${S}/* | grep -v "usr") ${D}/opt/${PN}

	# Update dirs permissions
	find ${D} -type d -exec chmod 755 {} +

	# Update links to /usr
	while read line; do 
		if [[ ! -z "$(grep ^l <<< $line)" ]]; then
			LINK_DEST=$(awk '{ print $NF }' <<< $line)
			LINK_NAME=$(awk '{ print $(NF-2) }' <<< $line)

			if [[ ! -z "$(grep ^usr/ <<< ${LINK_DEST})" ]]; then 
				ln -sf /${LINK_DEST} ${D}/opt/${PN}/${LINK_NAME}
			fi
		fi
	done <<< `ls -lah ${D}/opt/${PN}`

	ln -sf /opt/${PN}/AppRun ${D}/usr/local/bin/${PN}

	insinto / && doins -r / || die

}
