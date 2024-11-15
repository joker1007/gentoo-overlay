# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Wrapper script for Steam custom launch options"
HOMEPAGE="https://github.com/sonic2kk/steamtinkerlaunch"

if [[ ${PV} == 9999 ]] ; then
	EGIT_REPO_URI="https://github.com/sonic2kk/steamtinkerlaunch.git"
	inherit git-r3
else
	SRC_URI="https://github.com/sonic2kk/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

DEPEND=

RDEPEND="
	app-arch/unzip
	|| ( app-editors/vim-core dev-util/xxd )
	x11-apps/xprop
	x11-apps/xrandr
	x11-apps/xwininfo
	x11-misc/xdotool

	>=gnome-extra/yad-7.2
"

src_prepare() {
	default

	sed -e 's|PREFIX := /usr|PREFIX := $(DESTDIR)/usr|g' \
		-e "s|share/doc/${PN}|share/doc/${PF}|g" \
		-e '/sed "s:^PREFIX/d' \
		-i Makefile || die
}

pkg_postinst() {
	xdg_pkg_postinst
}
