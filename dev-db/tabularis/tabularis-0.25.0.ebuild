# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="Open-source desktop SQL workspace with built-in database drivers and plugins"
HOMEPAGE="https://tabularis.dev https://github.com/TabularisDB/tabularis"
SRC_URI="https://github.com/TabularisDB/tabularis/releases/download/v${PV}/${PN}_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-crypt/libsecret
	dev-libs/glib:2
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"

QA_PREBUILT="usr/bin/tabularis"

src_install() {
	dobin usr/bin/tabularis

	insinto /usr
	doins -r usr/share
}
