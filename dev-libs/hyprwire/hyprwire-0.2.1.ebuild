# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A fast and consistent wire protocol for IPC"
HOMEPAGE="https://github.com/hyprwm/hyprwire"
SRC_URI="https://github.com/hyprwm/${PN}/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="|| ( >=sys-devel/gcc-14:* >=llvm-core/clang-18:* )"

pkg_setup() {
	[[ ${MERGE_TYPE} == binary ]] && return

	tc-check-min_ver gcc 14
	tc-check-min_ver clang 18
}
