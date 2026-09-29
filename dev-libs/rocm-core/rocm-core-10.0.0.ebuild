# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
inherit cmake rocm-slot

DESCRIPTION="Library that provides ROCm release version and install path information"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocm-core"
SRC_URI="${ROCM_SYSTEMS_URI}/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
KEYWORDS="~amd64"

src_configure() {
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-DROCM_VERSION=${PV}
	)
	cmake_src_configure
}
