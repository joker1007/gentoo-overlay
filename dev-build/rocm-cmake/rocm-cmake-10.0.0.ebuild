# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
inherit cmake rocm-slot

DESCRIPTION="Radeon Open Compute CMake Modules"
HOMEPAGE="https://github.com/ROCm/rocm-cmake"
SRC_URI="https://github.com/ROCm/rocm-cmake/archive/${ROCM_TAG}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/rocm-cmake-${ROCM_TAG}"

LICENSE="MIT"
KEYWORDS="~amd64"
RESTRICT="test"

DOCS=( CHANGELOG.md LICENSE README.md )

PATCHES=(
	"${FILESDIR}"/${PN}-6.1.1-license.patch
	"${FILESDIR}"/${PN}-6.1.1-no-rocmchecks-warnings.patch
)

src_configure() {
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-Wno-dev
	)
	cmake_src_configure
}
