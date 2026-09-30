# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} python3_13t )

inherit cmake linux-info optfeature python-r1

DESCRIPTION="ROCm System Management Interface Library"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocm-smi-lib"
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/rocm-smi-lib.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/rocm-smi-lib"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
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
	# Just silences potential "git: command not found" QA warnings.
	sed -e "/find_program (GIT NAMES git)/d" -i CMakeLists.txt || die
	sed -e "/num_change_since_prev_pkg(\${VERSION_PREFIX})/d" -i cmake_modules/utils.cmake || die

	# https://bugs.gentoo.org/981854 (libc++)
	sed -e '0,/^#include/s//#include <chrono>\n#include/' -i src/rocm_smi_utils.cc || die

	local rocm_lib="${EPREFIX}/usr/$(get_libdir)/librocm_smi64.so.@VERSION_MAJOR@"
	sed -E "s|path_librocm =.+__file__.+|path_librocm = '${rocm_lib}'|" \
		-i python_smi_tools/rsmiBindingsInit.py.in || die
}

src_install() {
	cmake_src_install
	# installed via python_newscript/python_domodule instead
	rm -r "${ED}"/usr/libexec/rocm_smi "${ED}"/usr/bin/rocm-smi || die

	python_foreach_impl python_newscript python_smi_tools/rocm_smi.py rocm-smi
	python_foreach_impl python_domodule python_smi_tools/rsmiBindings.py
	python_foreach_impl python_domodule python_smi_tools/rsmiBindingsInit.py

	mv "${ED}"/usr/share/doc/rocm-smi-lib/* "${ED}/usr/share/doc/${PF}" || die
	rm -r "${ED}"/usr/share/doc/rocm-smi-lib || die
}

pkg_postinst() {
	optfeature "vendor and device names instead of hex device IDs" sys-apps/hwdata
}
