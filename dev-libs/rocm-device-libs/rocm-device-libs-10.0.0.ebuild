# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )
ROCM_SKIP_GLOBALS=1
inherit cmake flag-o-matic llvm-r2 rocm-slot

MY_P=llvm-project-rocm-${PV}
components=( "amd/device-libs" )

DESCRIPTION="Radeon Open Compute Device Libraries"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/device-libs"
SRC_URI="https://github.com/ROCm/llvm-project/archive/${ROCM_TAG}.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/llvm-project-${ROCM_TAG}/${components[0]}"

LICENSE="MIT"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}
		llvm-core/lld:\${LLVM_SLOT}
	")
"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/${PN}-6.2.0-test-bitcode-dir.patch"
)

src_unpack() {
	local archive="${MY_P}.tar.gz"
	ebegin "Unpacking from ${archive}"
	tar -x -z -o \
		-f "${DISTDIR}/${archive}" \
		"${components[@]/#/llvm-project-${ROCM_TAG}/}" || die
	eend ${?}
}

src_prepare() {
	# shellcheck disable=SC2016
	sed -e 's:${CMAKE_INSTALL_DATADIR}/doc/${CPACK_PACKAGE_NAME}:${CMAKE_INSTALL_DOCDIR}:' \
		-i CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	# Do not trust CMake with autoselecting Clang, as it autoselects the latest one
	# producing too modern LLVM bitcode and causing linker errors in other packages.
	llvm_prepend_path "${LLVM_SLOT}"
	local -x CC=${CHOST}-clang
	local -x CXX=${CHOST}-clang++
	strip-unsupported-flags

	# bitcode stays in upstream location: ${ROCM_PATH}/amdgcn/bitcode
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
	)
	cmake_src_configure
}

src_test() {
	# https://github.com/ROCm/llvm-project/issues/76
	local CMAKE_SKIP_TESTS=(
		compile_frexp__gfx600
		compile_fract__gfx600
		compile_native_rcp__gfx600
		compile_native_rsqrt__gfx600
		compile_fract__gfx700
		compile_native_rcp__gfx700
		compile_native_rsqrt__gfx700
		compile_native_rcp__gfx803
		compile_native_rsqrt__gfx803
		compile_atomic_work_item_fence__*
	)
	cmake_src_test
}
