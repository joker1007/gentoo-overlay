# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8


inherit git-r3

DESCRIPTION="ChimeraOS session on Gamescope"
HOMEPAGE="https://github.com/ChimeraOS/gamescope-session"

EGIT_REPO_URI="https://github.com/ChimeraOS/gamescope-session.git"
EGIT_BRANCH="main"
SRC_URI=""

LICENSE="MIT"
SLOT="0"

KEYWORDS="~amd64"

IUSE=""


src_install() {
	doins -r usr
	fperms +x /usr/bin/export-gpu
	fperms +x /usr/bin/gamescope-session-plus
	fperms +x /usr/share/gamescope-session-plus/gamescope-session-plus
}
