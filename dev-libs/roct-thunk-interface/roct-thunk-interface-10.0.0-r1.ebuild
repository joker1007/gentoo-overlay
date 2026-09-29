# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )
ROCM_SKIP_GLOBALS=1
inherit cmake flag-o-matic linux-info llvm-r2 rocm-slot

DESCRIPTION="Radeon Open Compute Thunk Interface"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/rocr-runtime/libhsakmt"
SRC_URI="${ROCM_SYSTEMS_URI}/rocr-runtime.tar.gz -> rocr-runtime-${PV}.tar.gz"
S="${WORKDIR}/rocr-runtime/libhsakmt"

CONFIG_CHECK="~HSA_AMD ~HMM_MIRROR ~ZONE_DEVICE ~DRM_AMDGPU ~DRM_AMDGPU_USERPTR"
LICENSE="MIT"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	sys-process/numactl
	x11-libs/libdrm[video_cards_amdgpu]
"
DEPEND="${RDEPEND}
	test? (
		$(llvm_gen_dep "llvm-core/llvm:\${LLVM_SLOT}")
		dev-cpp/gtest
	)"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/kfdtest-6.1.0-skipIPCtest.patch"
)

test_wrapper() {
	local S="$1"
	shift 1
	local CMAKE_USE_DIR="${S}"
	local BUILD_DIR="${S}_build"
	cd "${S}" || die
	"$@"
}

src_prepare() {
	sed -e "s/get_version ( \"1.0.0\" )/get_version ( \"${PV}\" )/" -i CMakeLists.txt || die

	# https://github.com/ROCm/ROCR-Runtime/issues/263
	sed -e "s/\${HSAKMT_TARGET} STATIC/\${HSAKMT_TARGET}/" -i CMakeLists.txt || die

	# Export functions used by rocr-runtime; upstream only builds hsakmt as a
	# static library, so the version script is missing them.
	# https://github.com/ROCm/rocm-systems/issues/284
	local sym syms=(
		hsaKmtCreateQueueExt
		hsaKmtCreateQueueV2
		hsaKmtModelEnabled
		hsaKmtRegisterGraphicsHandleToNodesExt
	)
	for sym in "${syms[@]}"; do
		sed -e "/^hsaKmtAisReadWriteFile;/a ${sym};" -i src/libhsakmt.ver || die
	done

	# extsem.c misses the internal header redefining HSAKMTAPI with default
	# visibility, so its functions are hidden by -fvisibility=hidden
	sed -e 's:^#include "hsakmt/hsakmt.h":#include "libhsakmt.h":' -i src/extsem.c || die

	cmake_src_prepare
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"

	# QA warnings
	append-cxxflags -Wno-unused-value

	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_DISABLE_FIND_PACKAGE_NUMA=ON # skip warning - will use find_library anyways
	)
	cmake_src_configure

	if use test; then
		# ODR violations (bug #956958)
		filter-lto

		export LIBHSAKMT_PATH="${BUILD_DIR}"
		test_wrapper "${S}/tests/kfdtest" cmake_src_configure
	fi
}

src_compile() {
	cmake_src_compile
	if use test; then
		LIBRARY_PATH="${BUILD_DIR}" test_wrapper "${S}/tests/kfdtest" cmake_src_compile
	fi
}

src_test() {
	check_amdgpu
	cd "${S}/tests/kfdtest_build/" || die
	./run_kfdtest.sh || die
}
