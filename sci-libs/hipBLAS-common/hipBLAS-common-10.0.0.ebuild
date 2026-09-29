# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
inherit cmake rocm-slot

DESCRIPTION="Common files shared by hipBLAS and hipBLASLt"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblas-common"
SRC_URI="${ROCM_LIBRARIES_URI}/hipblas-common.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/hipblas-common"

LICENSE="MIT"
KEYWORDS="~amd64"

BDEPEND="dev-build/rocm-cmake:${SLOT}"

src_configure() {
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
	)
	cmake_src_configure
}
