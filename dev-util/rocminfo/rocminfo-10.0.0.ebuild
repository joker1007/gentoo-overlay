# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} python3_13t )
inherit cmake python-r1

DESCRIPTION="ROCm Application for Reporting System Info"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocminfo"
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="UoI-NCSA"
SLOT="0/$(ver_cut 1-2)"
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
	local mycmakeargs=( -DROCRTST_BLD_TYPE=Release )
	cmake_src_configure
}

src_install() {
	cmake_src_install
	rm "${ED}/usr/bin/rocm_agent_enumerator" || die
	python_foreach_impl python_doexe rocm_agent_enumerator "${BUILD_DIR}"/rocm_agent_enumerator
}
