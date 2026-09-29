# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
ROCM_SKIP_GLOBALS=1
inherit cmake python-single-r1 rocm-slot

DESCRIPTION="ROCm Application for Reporting System Info"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocminfo"
SRC_URI="${ROCM_SYSTEMS_URI}/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="UoI-NCSA"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="dev-libs/rocr-runtime:${SLOT}
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -e "/CPACK_RESOURCE_FILE_LICENSE/d" -i CMakeLists.txt || die
	sed -e "/num_change_since_prev_pkg(/cset(NUM_COMMITS 0)" \
		-i cmake_modules/utils.cmake || die # Fix QA issue on "git not found"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-DROCRTST_BLD_TYPE=Release
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	python_fix_shebang "${ED}${ROCM_PREFIX}/bin/rocm_agent_enumerator"
}
