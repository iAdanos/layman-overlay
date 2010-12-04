# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/psb-kmod/psb-kmod-4.41.1_p10-r1.ebuild,v 1.2 2009/12/17 22:40:45 zmedico Exp $

EAPI="2"

inherit linux-info linux-mod

DESCRIPTION="kernel module for the intel gma500 (poulsbo)"
HOMEPAGE="https://launchpad.net/~gma500/+archive/ppa/+packages"
SRC_URI="http://www.ccube.de/poulsbo/src/psb-kernel-source_4.42.0-0ubuntu2~1104um3.tar.gz"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="x11-drivers/psb-firmware"
RDEPEND=""

S=${WORKDIR}/psb-kernel-source

src_unpack() {
	unpack ${A}
}

pkg_setup() {
	linux-mod_pkg_setup

	local CONFIG_CHECK="FB_CFB_FILLRECT FB_CFB_COPYAREA FB_CFB_IMAGEBLIT
	~FRAMEBUFFER_CONSOLE I2C_ALGOBIT AGP"
	local ERROR_AGP="You don't have CONFIG_AGP enabled in you kernel config."
	local ERROR_FB_CFB_FILLRECT="You don't have CONFIG_FB_CFB_FILLRECT enabled in you kernel config. To do this either hack drivers/video/Kconfig or enable an FB driver that pulls it in (for example VESAFB)"
	local ERROR_FB_CFB_COPYAREA="You don't have CONFIG_FB_CFB_FILLRECT enabled in you kernel config. To do this either hack drivers/video/Kconfig or enable an FB driver that pulls it in (for example VESAFB)"
	local ERROR_FB_CFB_IMAGEBLIT="You don't have CONFIG_FB_CFB_IMAGEBLIT enabled in you kernel config. To do this either hack drivers/video/Kconfig or enable an FB driver that pulls it in (for example VESAFB)"
	local WARNING_FBCON="You should really have CONFIG_FRAMEBUFFER_CONSOLE set in your kernel config. Otherwise you will get a seriously messed up console. You can work around this by loading the psb module with no_fb=1"

	check_extra_config

	linux_chkconfig_builtin "FRAMEBUFFER_CONSOLE" || ewarn "You really should not have CONFIG_FRAMEBUFFER_CONSOLE as a module. Otherwise you will get a seriously messed up console. You can work around this by loading the psb module with no_fb=1"
}

src_prepare()
{
       epatch "${FILESDIR}/01_2.6.32.dpatch"
       epatch "${FILESDIR}/02_agp_memory.dpatch"
       epatch "${FILESDIR}/04_drmpsb.dpatch"
       epatch "${FILESDIR}/05_edid-crash.dpatch"
#       epatch "${FILESDIR}/06_i2c-intelfb.dpatch"
       epatch "${FILESDIR}/08_irqreturn.dpatch"
       epatch "${FILESDIR}/use_udev.dpatch"
       epatch "${FILESDIR}/10_change_prefix.dpatch"
       epatch "${FILESDIR}/2.6.34.dpatch"
       epatch "${FILESDIR}/11_psb-Declare-firmware.dpatch"
       epatch "${FILESDIR}/12_psb-If-not-asking-for-debug-is-an-error-I-want-to-be.dpatch"
       epatch "${FILESDIR}/rt-kernel.dpatch"
       epatch "${FILESDIR}/2.6.36-ioctl.dpatch"
       epatch "${FILESDIR}/psb_driver.xf86AddModuleInfo.patch"

}


src_compile()
{
	# dirty hack :(
	LINUXDIR=/usr/src/linux emake DRM_MODULES=psb || die
}

src_install()
{
	MODULE_NAMES="drm-psb(kernel/drivers/gpu/drm:${S}:${S}) psb(kernel/drivers/gpu/drm:${S}:${S})"
	MODULESD_PSB_ALIASES=(
		"pci:v00008086d00008108sv*sd*bc*sc*i* psb"
		"pci:v00008086d00008109sv*sd*bc*sc*i* psb"
	)

	linux-mod_src_install
}
