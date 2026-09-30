# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )

inherit cmake llvm-r2

MY_P=llvm-project-rocm-${PV}
MY_TAG=therock-$(ver_cut 1-2)
components=( "amd/comgr" )

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/comgr"
SRC_URI="https://github.com/ROCm/llvm-project/archive/${MY_TAG}.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/llvm-project-${MY_TAG}/${components[0]}"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${PN}-6.4.1-extend-isa-compatibility-check.patch"
)

RDEPEND="
	dev-libs/rocm-device-libs:${SLOT}
	llvm-runtimes/clang-runtime:=
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}=
		llvm-core/lld:\${LLVM_SLOT}=
		llvm-core/llvm:\${LLVM_SLOT}=
	")
	dev-util/hipcc:${SLOT}
"
DEPEND="${RDEPEND}"

# Circular dependency: to build tests, hip compiler must be functional
BDEPEND="test? ( dev-util/hip:${SLOT} )"

CMAKE_BUILD_TYPE=Release

src_unpack() {
	local archive="${MY_P}.tar.gz"
	ebegin "Unpacking from ${archive}"
	tar -x -z -o \
		-f "${DISTDIR}/${archive}" \
		"${components[@]/#/llvm-project-${MY_TAG}/}" || die
	eend ${?}
}

src_prepare() {
	sed -e "s:\${CLANG_CMAKE_DIR}/../../../\*:${EPREFIX}/usr/lib/clang/${LLVM_SLOT}/include:" \
		-i cmake/opencl_header.cmake || die

	# std::unordered_set is included only transitively via ROCm's LLVM fork headers
	sed -e 's/^#include <csignal>$/&\n#include <unordered_set>/' \
		-i src/comgr-compiler.cpp || die

	# hotswap rewriter links LLVM component libraries, which are not installed
	# by llvm-core/llvm (only libLLVM.so); use the dylib like amd_comgr itself
	sed -e 's/^target_link_libraries(hotswap-rewriter PUBLIC/if(LLVM_LINK_LLVM_DYLIB)\n  set(hotswap_rewriter_llvm_libs LLVM)\nendif()\n&/' \
		-i src/hotswap/rewriter/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"

	local mycmakeargs=(
		-DCMAKE_STRIP=""  # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=$(usex test ON OFF)
		-DCOMGR_DISABLE_SPIRV=ON  # requires ROCm/SPIRV-LLVM-Translator (fork of dev-util/spirv-llvm-translator)
	)
	# Prevent CMake from finding systemwide hip, which breaks tests
	use test && mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_hip=ON )
	cmake_src_configure
}

src_test() {
	cmake_src_test
}
