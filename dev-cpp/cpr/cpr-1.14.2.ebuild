# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++ Requests: Curl for People, a spiritual port of Python Requests."
HOMEPAGE="https://github.com/libcpr/cpr/"

SRC_URI="https://github.com/libcpr/cpr/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="test"

RDEPEND="
	dev-libs/openssl:=
	net-libs/libpsl
	net-misc/curl[psl(-)]
"
DEPEND="${RDEPEND}"

src_prepare() {
	cmake_src_prepare

	sed -i -e 's/-Werror//' CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DCPR_USE_SYSTEM_CURL=ON
		-DCPR_USE_SYSTEM_LIB_PSL=ON
		-DCPR_FORCE_OPENSSL_BACKEND=ON
	)
	cmake_src_configure
}
