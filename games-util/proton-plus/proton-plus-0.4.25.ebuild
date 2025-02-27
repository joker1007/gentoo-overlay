EAPI=8

inherit meson xdg gnome2-utils

DESCRIPTION="A modern compatibility tools manager for Linux. "
HOMEPAGE="https://github.com/Vladimir-csp/uwsm"
SRC_URI="https://github.com/Vysp3r/ProtonPlus/archive/refs/tags/v${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-lang/vala
	gui-libs/gtk
	gui-libs/libadwaita
	net-libs/libsoup
	app-arch/libarchive
	dev-util/desktop-file-utils
	dev-libs/libgee
	app-alternatives/ninja
	dev-build/meson
"

DEPEND="${RDEPEND}"

S="${WORKDIR}/ProtonPlus-${PV}"

src_configure() {
	valac=$(equery f dev-lang/vala | grep bin/valac | head -n 1)
	VALAC=${valac} meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
