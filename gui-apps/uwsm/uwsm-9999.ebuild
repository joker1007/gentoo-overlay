EAPI=8

inherit git-r3 meson

DESCRIPTION="Universal Wayland Session Manager"
HOMEPAGE="https://github.com/Vladimir-csp/uwsm"
EGIT_REPO_URI="https://github.com/Vladimir-csp/uwsm.git"

PROPERTIES="live"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+uuctl +fumon +uwsm-app"

RDEPEND="
	dev-python/pyxdg
	dev-python/dbus-python
	sys-apps/dbus-broker
"
DEPEND="${RDEPEND}"

src_configure() {
	local emesonargs=(
		$(meson_feature uuctl uuctl)
		$(meson_feature fumon fumon)
		$(meson_feature uwsm-app uwsm-app)
	)
	meson_src_configure
}
