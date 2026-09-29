# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 23 )
PYTHON_COMPAT=( python3_{12..14} )

inherit cmake flag-o-matic llvm-r2 multiprocessing python-any-r1 rocm-slot

DESCRIPTION="AMD's library for BLAS on ROCm"
HOMEPAGE="https://github.com/ROCm/rocm-libraries/tree/develop/projects/rocblas"
# Tensile is only used at build time to generate GEMM kernels; it is used
# in-tree instead of a slotted dev-util/Tensile (python modules would collide).
SRC_URI="
	${ROCM_LIBRARIES_URI}/rocblas.tar.gz -> rocblas-${PV}.tar.gz
	${ROCM_LIBRARIES_URI}/tensile.tar.gz -> tensile-${PV}.tar.gz
"
S="${WORKDIR}/rocblas"
TENSILE_S="${WORKDIR}/tensile"

LICENSE="MIT BSD"
KEYWORDS="~amd64"
REQUIRED_USE="${ROCM_REQUIRED_USE}"
RESTRICT="test"

RDEPEND="
	dev-util/hip:${SLOT}
"
DEPEND="
	${RDEPEND}
	>=dev-cpp/msgpack-cxx-6.0.0
"
BDEPEND="
	dev-build/rocm-cmake:${SLOT}
	$(python_gen_any_dep '
		dev-python/joblib[${PYTHON_USEDEP}]
		dev-python/msgpack[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
	')
"

QA_FLAGS_IGNORED="${ROCM_PREFIX#/}/lib/rocblas/library/.*"

PATCHES=(
	"${FILESDIR}"/${PN}-7.1.0-no-git.patch
)

python_check_deps() {
	python_has_version \
		"dev-python/joblib[${PYTHON_USEDEP}]" \
		"dev-python/msgpack[${PYTHON_USEDEP}]" \
		"dev-python/pyyaml[${PYTHON_USEDEP}]" \
		"dev-python/rich[${PYTHON_USEDEP}]"
}

pkg_setup() {
	llvm-r2_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	# Tensile: use clang of LLVM_SLOT instead of amdclang
	pushd "${TENSILE_S}/Tensile" >/dev/null || die
	sed -e "s/amdclang/clang/g" -i Utilities/Toolchain.py Common.py || die
	sed -e "/HipClangVersion/s/0.0.0/$("$(rocm_slot_prefix)"/bin/hipconfig -v)/" -i Common.py || die
	popd >/dev/null || die
}

src_configure() {
	llvm_prepend_path "${LLVM_SLOT}"
	rocm_use_clang

	# too many warnings
	append-cxxflags -Wno-explicit-specialization-storage-class -Wno-unused-value

	local mycmakeargs=(
		$(rocm_slot_cmake_args)
		-DROCM_SYMLINK_LIBS=OFF
		-DGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_WITH_TENSILE=ON
		-DBUILD_WITH_PIP=OFF
		-DBUILD_WITH_HIPBLASLT=OFF
		-DTensile_ROOT="${TENSILE_S}/Tensile"
		-DTensile_DIR="${TENSILE_S}/Tensile/cmake"
		-DTensile_COMPILER="${CXX}"
		-DTensile_CPU_THREADS="$(makeopts_jobs)"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocblas"
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_BENCHMARKS=OFF
		-DLINK_BLIS=OFF
		-Wno-dev
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Stop llvm-strip from removing .strtab section from *.hsaco files,
	# otherwise rocclr/elf/elf.cpp complains with "failed: null sections(STRTAB)" and crashes
	dostrip -x "${ROCM_PREFIX}/lib/rocblas/library/"
}
