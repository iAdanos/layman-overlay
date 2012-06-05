# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
SLOT="0"
ETYPE="sources"

CKV=`date +%F`

inherit kernel-2 git-2
detect_version

K_NOUSENAME="yes"
#K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git"
EGIT_PROJECT="linux-next"
EGIT_MASTER="master"

DESCRIPTION="The linux-next integration testing tree"
HOMEPAGE="http://www.kernel.org"
SRC_URI=""

KEYWORDS="~amd64 ~x86"
IUSE="deblob"
