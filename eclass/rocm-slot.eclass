# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rocm-slot.eclass
# @MAINTAINER:
# joker1007 <kakyoin.hierophant@gmail.com>
# @SUPPORTED_EAPIS: 8
# @BLURB: Common functions for slotted ROCm packages installed under /usr/lib64/rocm/<slot>
# @DESCRIPTION:
# Slotted ROCm stack for versions not (yet) supported by ::gentoo.
#
# Every package of a given ROCm release is installed into
# ROCM_PREFIX (/usr/lib64/rocm/<major>.<minor>) using the upstream /opt/rocm
# layout (bin/, include/, lib/, lib/cmake/, amdgcn/bitcode, libexec/ ...),
# so it can coexist with the unslotted ::gentoo ROCm stack in /usr.
# (Not /usr/lib/rocm: FEATURES=multilib-strict rejects ELF64 files under /usr/lib.)
#
# The prefix has lib/llvm -> /usr/lib/llvm/<LLVM_SLOT> symlink (installed by
# dev-util/hipcc), so tools expecting ${ROCM_PATH}/lib/llvm/bin/clang work.
#
# Users select this stack with:
#   export ROCM_PATH=/usr/lib64/rocm/<slot> HIP_PATH=/usr/lib64/rocm/<slot>
#   export PATH=/usr/lib64/rocm/<slot>/bin:${PATH}
#   cmake -DCMAKE_PREFIX_PATH=/usr/lib64/rocm/<slot> ...

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_ROCM_SLOT_ECLASS} ]]; then
_ROCM_SLOT_ECLASS=1

inherit flag-o-matic

# @ECLASS_VARIABLE: ROCM_SLOT
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# ROCm release slot, e.g. "10.0".
ROCM_SLOT=$(ver_cut 1-2)

# @ECLASS_VARIABLE: ROCM_PREFIX
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Install prefix of this ROCm slot, without EPREFIX.
ROCM_PREFIX="/usr/lib64/rocm/${ROCM_SLOT}"

# @ECLASS_VARIABLE: ROCM_TAG
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Upstream git tag of this release (ROCm >= 7.12 is tagged "therock-X.Y[.Z]").
if [[ $(ver_cut 3) == 0 ]]; then
	ROCM_TAG="therock-${ROCM_SLOT}"
else
	ROCM_TAG="therock-${PV}"
fi

# @ECLASS_VARIABLE: ROCM_SYSTEMS_URI
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Base URI of per-project tarballs from ROCm/rocm-systems.
ROCM_SYSTEMS_URI="https://github.com/ROCm/rocm-systems/releases/download/${ROCM_TAG}"

# @ECLASS_VARIABLE: ROCM_LIBRARIES_URI
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Base URI of per-project tarballs from ROCm/rocm-libraries.
ROCM_LIBRARIES_URI="https://github.com/ROCm/rocm-libraries/releases/download/${ROCM_TAG}"

# @ECLASS_VARIABLE: ROCM_SKIP_GLOBALS
# @DEFAULT_UNSET
# @PRE_INHERIT
# @DESCRIPTION:
# Set to non-empty to skip AMDGPU_TARGETS IUSE / ROCM_USEDEP / ROCM_REQUIRED_USE.

_rocm_slot_set_globals() {
	SLOT="${ROCM_SLOT}"

	[[ -n ${ROCM_SKIP_GLOBALS} ]] && return

	local unofficial_amdgpu_targets official_amdgpu_targets
	case ${ROCM_SLOT} in
		10.*)
			unofficial_amdgpu_targets=(
				gfx803 gfx900 gfx906
				gfx1010 gfx1011 gfx1012
				gfx1030 gfx1031 gfx1103
			)
			official_amdgpu_targets=(
				gfx908 gfx90a gfx942 gfx950
				gfx1100 gfx1101 gfx1102
				gfx1150 gfx1151 gfx1152 gfx1153
				gfx1200 gfx1201
			)
			;;
		*)
			die "${ECLASS}: unknown ROCm slot ${ROCM_SLOT}, update AMDGPU targets"
			;;
	esac

	local iuse_flags=(
		"${official_amdgpu_targets[@]/#/+amdgpu_targets_}"
		"${unofficial_amdgpu_targets[@]/#/amdgpu_targets_}"
	)
	IUSE="${iuse_flags[*]}"

	local all_amdgpu_targets=(
		"${official_amdgpu_targets[@]}"
		"${unofficial_amdgpu_targets[@]}"
	)
	local allflags=( "${all_amdgpu_targets[@]/#/amdgpu_targets_}" )
	ROCM_REQUIRED_USE=" || ( ${allflags[*]} )"

	local optflags=${allflags[@]/%/(-)?}
	ROCM_USEDEP=${optflags// /,}
}
_rocm_slot_set_globals
unset -f _rocm_slot_set_globals

# @FUNCTION: get_amdgpu_flags
# @USAGE: get_amdgpu_flags
# @DESCRIPTION:
# Output a semicolon-separated list of enabled AMDGPU targets.
get_amdgpu_flags() {
	echo $(printf "%s;" ${AMDGPU_TARGETS[@]})
}

# @FUNCTION: rocm_slot_prefix
# @USAGE: rocm_slot_prefix
# @DESCRIPTION:
# Output the prefix of this ROCm slot, including EPREFIX.
rocm_slot_prefix() {
	echo "${EPREFIX}${ROCM_PREFIX}"
}

# @FUNCTION: rocm_slot_cmake_args
# @USAGE: mycmakeargs+=( $(rocm_slot_cmake_args) )
# @DESCRIPTION:
# Output CMake arguments which install into the slot prefix, look for
# dependencies in it first, and embed RUNPATH so that libraries of this slot
# are preferred over the ::gentoo ones in /usr/lib64.
rocm_slot_cmake_args() {
	local prefix=$(rocm_slot_prefix)
	local prefix_path="${prefix}"
	if declare -f get_llvm_prefix >/dev/null && [[ -n ${LLVM_SLOT} ]]; then
		prefix_path+=";$(get_llvm_prefix)"
	fi
	echo \
		-DCMAKE_INSTALL_PREFIX="${prefix}" \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}" \
		-DCMAKE_PREFIX_PATH="${prefix_path}" \
		-DROCM_PATH="${prefix}" \
		-DCMAKE_SKIP_RPATH=OFF \
		-DCMAKE_SKIP_INSTALL_RPATH=OFF \
		-DCMAKE_INSTALL_RPATH="${prefix}/lib"
}

# @FUNCTION: rocm_add_sandbox
# @USAGE: rocm_add_sandbox [-w]
# @DESCRIPTION:
# Add AMDGPU device files to the sandbox (predict, or write with -w).
rocm_add_sandbox() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	local i
	for i in /dev/kfd /dev/dri/render* /dev/accel/accel*; do
		if [[ ! -c $i ]]; then
			continue
		elif [[ $1 == '-w' ]]; then
			addwrite "$i"
		else
			addpredict "$i"
		fi
	done
}

# @FUNCTION: check_amdgpu
# @USAGE: check_amdgpu
# @DESCRIPTION:
# Make sure the GPU is accessible from the sandbox, die otherwise.
check_amdgpu() {
	if [[ ! -c /dev/kfd ]]; then
		eerror "Device /dev/kfd does not exist!"
		die "/dev/kfd is missing"
	fi

	local device
	for device in /dev/kfd /dev/dri/render* /dev/accel/accel*; do
		[[ ! -c ${device} ]] && continue
		addwrite "${device}"
		if [[ ! -r ${device} || ! -w ${device} ]]; then
			eerror "Cannot read or write ${device}!"
			ewarn "Check if portage user is in render group."
			die "${device} inaccessible"
		fi
	done
}

# @FUNCTION: rocm_use_clang
# @USAGE: rocm_use_clang
# @DESCRIPTION:
# Use clang of LLVM_SLOT as CC/CXX for HIP code, and export ROCM_PATH
# of this slot. Requires llvm-r2.
rocm_use_clang() {
	[[ -n ${LLVM_SLOT} ]] || die "${FUNCNAME[0]} requires llvm-r2"
	local clangpath="$(get_llvm_prefix)/bin"
	export CC="${clangpath}/${CHOST}-clang"
	export CXX="${clangpath}/${CHOST}-clang++"
	# clang is not under ROCM_PATH, so it cannot detect ROCm by itself;
	# clang honors the ROCM_PATH environment variable like --rocm-path
	export ROCM_PATH="$(rocm_slot_prefix)"
	# otherwise test-flags-HIPCXX uses "hipconfig" from PATH, i.e. the
	# unslotted ROCm with an older clang, and drops every flag (even -O2)
	export HIPCXX="${CXX}"
	strip-unsupported-flags
	export CXXFLAGS=$(test-flags-HIPCXX ${CXXFLAGS})

	# ROCm's LLVM fork uses the old offload driver for HIP by default,
	# upstream LLVM >= 23 the new one. Keep ROCm's (tested) default.
	append-cxxflags --no-offload-new-driver
	append-ldflags --no-offload-new-driver
}

fi
