# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_SKIP_GLOBALS=1
LLVM_COMPAT=( 23 )

inherit cmake flag-o-matic llvm-r2 rocm-slot

DESCRIPTION="C++ Heterogeneous-Compute Interface for Portability"
HOMEPAGE="https://github.com/ROCm/rocm-systems/tree/develop/projects/clr"
SRC_URI="
	${ROCM_SYSTEMS_URI}/clr.tar.gz -> rocm-clr-${PV}.tar.gz
	${ROCM_SYSTEMS_URI}/${PN}.tar.gz -> ${P}.tar.gz
"
S="${WORKDIR}/clr"
HIP_S="${WORKDIR}/hip"

LICENSE="MIT"
KEYWORDS="~amd64"
IUSE="debug"

# many tests are broken; also tests run against installed version, not built one
RESTRICT="test"

DEPEND="
	dev-util/rocminfo:${SLOT}
	dev-libs/rocm-comgr:${SLOT}
	dev-libs/rocr-runtime:${SLOT}
	x11-base/xorg-proto
	virtual/opengl[X]
"
BDEPEND="
	dev-util/hipcc:${SLOT}
"
RDEPEND="${DEPEND}
	~dev-libs/rocm-core-${PV}:${SLOT}
	dev-util/hipcc:${SLOT}
	dev-libs/rocm-device-libs:${SLOT}
	dev-libs/roct-thunk-interface:${SLOT}
"

PATCHES=(
	"${FILESDIR}/${PN}-6.3.0-no-isystem-usr-include.patch"
	"${FILESDIR}/${PN}-6.3.0-clr-fix-libcxx.patch"
	"${FILESDIR}/${PN}-7.1.0-no-hipother-install.patch"
	"${FILESDIR}/${PN}-7.2.0-noinline-fixes.patch"
	"${FILESDIR}/${PN}-10.0.0-aligned-new.patch"
)

QA_FLAGS_IGNORED="${ROCM_PREFIX#/}/lib/libhiprtc-builtins.*"

src_prepare() {
	pushd "${HIP_S}" >/dev/null || die
	# FindHIP.cmake: set HIP and HIP Clang paths directly, don't search using heuristics
	sed -e "s:# Search for HIP installation:set(HIP_ROOT_DIR \"$(rocm_slot_prefix)\"):" \
		-e "s:#Set HIP_CLANG_PATH:set(HIP_CLANG_PATH \"$(get_llvm_prefix -d)/bin\"):" \
		-i "cmake/FindHIP.cmake" || die
	popd >/dev/null || die

	sed -e "s/ -Werror//g" -i "hipamd/src/CMakeLists.txt" || die

	# do not install /usr/share/doc/${P}-asan
	sed -e "/asan COMPONENT asan/d" -i hipamd/packaging/CMakeLists.txt || die

	sed -e "s/@HIP_INSTALLS_HIPCC@/ON/g" -i hipamd/hip-config.cmake.in || die

	# skip installation of hipcc: installed via dev-util/hipcc
	sed -e "s/NOT \${HIPCC_BIN_DIR}/INSTALL_HIPCC AND NOT \${HIPCC_BIN_DIR}/" \
		-i "hipamd/CMakeLists.txt" || die

	sed -e "/cmake_minimum_required/ s/3\.[35]/3.10/" \
		-i opencl/khronos/icd/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# -Werror=strict-aliasing
	# https://bugs.gentoo.org/858383
	# Do not trust it for LTO either
	append-flags -fno-strict-aliasing
	filter-lto

	use debug && CMAKE_BUILD_TYPE="Debug"

	# Fix ld.lld linker error: https://github.com/ROCm/HIP/issues/3382
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-D__HIP_ENABLE_PCH=OFF

		-DCLR_BUILD_HIP=ON
		-DCLR_BUILD_OCL=OFF

		-DHIP_COMMON_DIR="${HIP_S}"
		-DHIP_ENABLE_ROCPROFILER_REGISTER=OFF
		-DHIPCC_BIN_DIR="$(rocm_slot_prefix)/bin"

		-DHIP_PLATFORM="amd"
		-DOpenGL_GL_PREFERENCE="GLVND"
		-DUSE_PROF_API=OFF

		-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
	)

	cmake_src_configure
}
