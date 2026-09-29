# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )
inherit cmake fortran-2 llvm-r2 rocm-slot

DESCRIPTION="ROCm BLAS marshalling library"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/hipblas"
SRC_URI="${ROCM_LIBRARIES_URI}/hipblas.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/hipblas"

LICENSE="MIT"
KEYWORDS="~amd64"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RDEPEND="
	sci-libs/rocBLAS:${SLOT}[${ROCM_USEDEP}]
"
DEPEND="
	dev-util/hip:${SLOT}
	sci-libs/hipBLAS-common:${SLOT}
	${RDEPEND}
"

PATCHES=(
	"${FILESDIR}"/${PN}-6.3.0-no-git.patch
)

pkg_setup() {
	llvm-r2_pkg_setup
	fortran-2_pkg_setup
}

src_configure() {
	rocm_use_clang

	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		# hipBLAS is a wrapper of rocBLAS which has tests
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_BENCHMARKS=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_WITH_SOLVER=OFF
		-DGPU_TARGETS="$(get_amdgpu_flags)"
	)

	cmake_src_configure
}
