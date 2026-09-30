# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic linux-info llvm-r2

DESCRIPTION="Radeon Open Compute Runtime"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocr-runtime"
SRC_URI="https://github.com/ROCm/rocm-systems/releases/download/therock-$(ver_cut 1-2)/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"
IUSE="debug"

CONFIG_CHECK="~HSA_AMD ~HMM_MIRROR ~ZONE_DEVICE ~DRM_AMDGPU ~DRM_AMDGPU_USERPTR"

# libhsakmt is built within rocr-runtime (like upstream/TheRock) and linked
# statically into libhsa-runtime64; it replaces dev-libs/roct-thunk-interface.
COMMON_DEPEND="
	dev-libs/elfutils
	sys-process/numactl
	x11-libs/libdrm[video_cards_amdgpu]
"
DEPEND="${COMMON_DEPEND}
	dev-libs/rocm-device-libs:${SLOT}
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}=
		llvm-core/lld:\${LLVM_SLOT}=
	")
"
RDEPEND="${DEPEND}
	!dev-libs/roct-thunk-interface
"
BDEPEND="app-editors/vim-core"
	# vim-core is needed for "xxd"

# skip false positive detection in samples, bug #958188
CMAKE_QA_COMPAT_SKIP=1

src_prepare() {
	cd "${S}/runtime/hsa-runtime" || die

	# Gentoo installs "*.bc" to "/usr/lib" instead of a "[path]/bitcode" directory ...
	sed -e "s:\"-O2 :\"--rocm-path=${EPREFIX}/usr/lib/ -O2 :" -i image/blit_src/CMakeLists.txt || die

	cd "${S}" || die
	cmake_src_prepare
}

src_configure() {
	# -Werror=odr
	# https://bugs.gentoo.org/856091
	# https://github.com/ROCm/ROCR-Runtime/issues/182
	filter-lto

	llvm_prepend_path "${LLVM_SLOT}"

	use debug || append-cxxflags "-DNDEBUG"

	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_rocprofiler-register=ON
		-Wno-dev
	)

	cmake_src_configure
}
