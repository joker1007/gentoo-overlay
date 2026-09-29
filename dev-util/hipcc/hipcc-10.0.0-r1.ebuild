# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )
ROCM_SKIP_GLOBALS=1
inherit cmake llvm-r2 rocm-slot

MY_P=llvm-project-rocm-${PV}
components=( "amd/hipcc" )

DESCRIPTION="Radeon Open Compute hipcc"
HOMEPAGE="https://github.com/ROCm/llvm-project/tree/amd-staging/amd/hipcc"
SRC_URI="https://github.com/ROCm/llvm-project/archive/${ROCM_TAG}.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/llvm-project-${ROCM_TAG}/${components[0]}"

LICENSE="Apache-2.0 MIT"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="
	$(llvm_gen_dep "
		llvm-runtimes/compiler-rt:\${LLVM_SLOT}=
		llvm-core/llvm:\${LLVM_SLOT}=
		llvm-core/clang:\${LLVM_SLOT}=
	")
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-10.0.0-slotted-rocm-path.patch
)

src_unpack() {
	local archive="${MY_P}.tar.gz"
	ebegin "Unpacking from ${archive}"
	tar -x -z -o \
		-f "${DISTDIR}/${archive}" \
		"${components[@]/#/llvm-project-${ROCM_TAG}/}" || die
	eend ${?}
}

src_configure() {
	local mycmakeargs=(
		$(rocm_slot_cmake_args)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	# remove bat files...
	rm -rf "${ED}${ROCM_PREFIX}/hip" || die

	# hipcc detects its ROCm root by looking for ../lib/llvm/bin,
	# and uses ${ROCM_PATH}/lib/llvm/bin/clang as HIP compiler.
	dosym -r "/usr/lib/llvm/${LLVM_SLOT}" "${ROCM_PREFIX}/lib/llvm"
}
