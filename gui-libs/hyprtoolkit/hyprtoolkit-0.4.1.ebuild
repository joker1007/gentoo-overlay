# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A modern C++ Wayland-native GUI toolkit"
HOMEPAGE="https://github.com/hyprwm/hyprtoolkit"
SRC_URI="https://github.com/hyprwm/${PN}/archive/refs/tags/v${PV}/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD"

SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	>=gui-libs/hyprutils-0.11.0:=
	>=gui-libs/aquamarine-0.10.0:=
	>=dev-libs/hyprgraphics-0.3.0
	>=dev-libs/hyprlang-0.6.0
	>=dev-util/hyprwayland-scanner-0.4.0
	dev-libs/wayland
	x11-libs/pixman
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/cairo
	dev-libs/iniparser
	kde-frameworks/qqc2-desktop-style:6
"

DEPEND="${RDEPEND}"
