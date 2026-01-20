# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A waybar weather module with automatic geolocation lookup "
HOMEPAGE="https://github.com/wneessen/waybar-weather"
SRC_URI="https://github.com/wneessen/${PN}/releases/download/v${PV}/waybar-weather_${PV}_linux_amd64.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	dobin waybar-weather
}
