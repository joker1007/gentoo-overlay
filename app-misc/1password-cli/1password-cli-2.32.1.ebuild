# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The world’s most-loved password manager CLI"
HOMEPAGE="https://1password.com"
SRC_URI="
amd64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_amd64_v${PV}.zip -> ${P}-amd64.zip )
arm64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_arm64_v${PV}.zip -> ${P}-arm64.zip )
"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip test bindist"


DEPEND="
	acct-group/onepassword
"
BDEPEND="app-arch/unzip"

QA_FLAGS_IGNORED="usr/bin/op"

src_unpack() {
	if use amd64; then
		unzip -q ${DISTDIR}/${P}-amd64.zip -d ${S} || die
	elif use arm64; then
		unzip -q ${DISTDIR}/${P}-arm64.zip -d ${S} || die
	fi
}

src_install() {
	exeinto /usr/bin
	doexe op

	fowners root:onepassword-cli /usr/bin/op
	fperms g+s /usr/bin/op
}
