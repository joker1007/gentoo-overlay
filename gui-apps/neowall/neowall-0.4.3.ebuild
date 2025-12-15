# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib

DESCRIPTION="GPU-Accelerated Live Wallpapers for Wayland & X11"
HOMEPAGE="https://github.com/1ay1/neowall"
SRC_URI="https://github.com/1ay1/${PN}/releases/download/v${PV}/neowall-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/wayland
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
}
