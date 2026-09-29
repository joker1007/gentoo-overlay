# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
ROCM_SKIP_GLOBALS=1
inherit cmake linux-info optfeature python-single-r1 rocm-slot

DESCRIPTION="ROCm System Management Interface Library"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocm-smi-lib"
SRC_URI="${ROCM_SYSTEMS_URI}/rocm-smi-lib.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/rocm-smi-lib"

LICENSE="MIT"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	x11-libs/libdrm[video_cards_amdgpu]
"

CONFIG_CHECK="~HSA_AMD ~DRM_AMDGPU"

src_prepare() {
	cmake_src_prepare

	# Disable code that relies on missing .git directory.
	sed -e "/find_program (GIT NAMES git)/d" -i CMakeLists.txt || die
	sed -e "/num_change_since_prev_pkg(\${VERSION_PREFIX})/d" -i cmake_modules/utils.cmake || die

	# https://bugs.gentoo.org/981854 (libc++)
	sed -e '0,/^#include/s//#include <chrono>\n#include/' -i src/rocm_smi_utils.cc || die

	# Always load the library of this slot
	local rocm_lib="$(rocm_slot_prefix)/lib/librocm_smi64.so.@VERSION_MAJOR@"
	sed -E "s|path_librocm =.+__file__.+|path_librocm = '${rocm_lib}'|" \
		-i python_smi_tools/rsmiBindingsInit.py.in || die
}

src_configure() {
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	python_fix_shebang "${ED}${ROCM_PREFIX}/libexec/rocm_smi"
}

pkg_postinst() {
	optfeature "vendor and device names instead of hex device IDs" sys-apps/hwdata
}
