# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="General purpose mod manager with LOOT integration"
HOMEPAGE="https://github.com/limo-app/limo"
SRC_URI="https://github.com/limo-app/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-arch/libarchive:=
	app-arch/lz4:=
	app-arch/unrar:=
	app-arch/zstd:=
	dev-cpp/cpr:=
	=dev-cpp/libloot-0.25.5*
	dev-libs/jsoncpp:=
	dev-libs/openssl:=
	dev-libs/pugixml:=
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	sys-libs/zlib:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-build/cmake-3.25
"

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_LIBUNRAR=ON
		-DLIMO_INSTALL_PREFIX="/usr"
	)
	cmake_src_configure
}
