# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="Yet Another Dialog"
HOMEPAGE="https://github.com/v1cont/yad"
SRC_URI="https://github.com/v1cont/yad/releases/download/v9.2/yad-${PV}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+tray html spell sourceview standalone +tools +icon-browser"

DEPEND=">=x11-libs/gtk+-3.22.0"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
}

src_configure() {
	local myconf=

	if use tray; then
		myconf="${myconf} --enable-tray"
	fi

	if use html; then
		myconf="${myconf} --enable-html"
	fi

	if use spell; then
		myconf="${myconf} --enable-spell"
	fi

	if use sourceview; then
		myconf="${myconf} --enable-sourceview"
	fi

	if use standalone; then
		myconf="${myconf} --enable-standalone"
	fi

	if use tools; then
		myconf="${myconf} --enable-tools"
	fi

	if use icon-browser; then
		myconf="${myconf} --enable-icon-browser"
	fi

	echo ${myconf}

	econf \
		${myconf}
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
