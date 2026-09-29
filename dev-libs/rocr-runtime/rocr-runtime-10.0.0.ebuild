# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )
ROCM_SKIP_GLOBALS=1
inherit cmake flag-o-matic llvm-r2 rocm-slot

DESCRIPTION="Radeon Open Compute Runtime"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocr-runtime"
SRC_URI="${ROCM_SYSTEMS_URI}/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
KEYWORDS="~amd64"
IUSE="debug"

COMMON_DEPEND="dev-libs/elfutils
	x11-libs/libdrm"
DEPEND="${COMMON_DEPEND}
	dev-libs/roct-thunk-interface:${SLOT}
	dev-libs/rocm-device-libs:${SLOT}
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}=
		llvm-core/lld:\${LLVM_SLOT}=
	")
"
RDEPEND="${DEPEND}"
BDEPEND="app-editors/vim-core"
	# vim-core is needed for "xxd"

PATCHES=(
	"${FILESDIR}/${PN}-7.2.0-use-system-hsakmt.patch"
)

# skip false positive detection in samples, bug #958188
CMAKE_QA_COMPAT_SKIP=1

src_prepare() {
	# Blit kernels are built with clang; point it at the device libs of this slot
	sed -e "s:\"-O2 :\"--rocm-path=$(rocm_slot_prefix) -O2 :" \
		-i runtime/hsa-runtime/image/blit_src/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# -Werror=odr
	# https://bugs.gentoo.org/856091
	filter-lto

	llvm_prepend_path "${LLVM_SLOT}"

	use debug || append-cxxflags "-DNDEBUG"

	# hsakmt/linux/kfd_ioctl.h is not installed by roct-thunk-interface
	# (excluded upstream), but it is shipped in this tarball
	append-cxxflags -idirafter "${S}/libhsakmt/include"

	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-DCMAKE_DISABLE_FIND_PACKAGE_rocprofiler-register=ON
		-Wno-dev
	)

	cmake_src_configure
}
