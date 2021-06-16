# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..9} )

inherit distutils-r1

DESCRIPTION="Fan controller for AMD graphics cards running the amdgpu driver on Linux"
HOMEPAGE="https://github.com/zzkW35/amdgpu-fan"

KEYWORDS="~amd64"

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/zzkW35/amdgpu-fan.git"
	EGIT_SUBMODULES=('-*')
	EGIT_BRANCH="master"
	inherit git-r3
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/zzkW35/amdgpu-fan/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}

	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}"
