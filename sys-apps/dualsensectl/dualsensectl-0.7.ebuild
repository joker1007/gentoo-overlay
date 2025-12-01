# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson shell-completion

DESCRIPTION="Linux tool for controlling PS5 DualSense controller "
HOMEPAGE="https://github.com/nowrep/dualsensectl"
SRC_URI="https://github.com/nowrep/dualsensectl/archive/refs/tags/v0.7.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	virtual/libudev
	dev-libs/hidapi
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	meson_src_install

	newbashcomp completion/dualsensectl dualsensectl
	newzshcomp completion/_dualsensectl _dualsensectl
}
