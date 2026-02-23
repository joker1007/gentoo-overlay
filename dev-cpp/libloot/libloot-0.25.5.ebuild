# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ESPLUGIN_PV="6.1.1"
LIBLOADORDER_PV="18.2.2"
LCI_PV="5.2.0"

CRATES="
	adler2@2.0.0
	aho-corasick@1.1.3
	anes@0.1.6
	anstyle@1.0.6
	anstyle@1.0.7
	autocfg@1.2.0
	bitflags@2.5.0
	block-buffer@0.10.4
	bumpalo@3.16.0
	cast@0.3.0
	cfg-if@1.0.0
	ciborium@0.2.2
	ciborium-io@0.2.2
	ciborium-ll@0.2.2
	clap@4.5.4
	clap_builder@4.5.2
	clap_lex@0.7.0
	const-random@0.1.18
	const-random-macro@0.1.16
	cpufeatures@0.2.12
	crc32fast@1.4.0
	crc32fast@1.4.2
	criterion@0.5.1
	criterion-plot@0.5.0
	crossbeam-deque@0.8.5
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.19
	crunchy@0.2.2
	crypto-common@0.1.6
	dataview@1.0.1
	derive_pod@0.1.2
	digest@0.10.7
	dirs@6.0.0
	dirs-sys@0.5.0
	dlv-list@0.5.2
	either@1.11.0
	encoding_rs@0.8.34
	encoding_rs@0.8.35
	errno@0.3.8
	errno@0.3.9
	esplugin@6.1.1
	fastrand@2.1.1
	flate2@1.0.34
	generic-array@0.14.7
	getrandom@0.2.14
	getrandom@0.3.1
	half@2.4.1
	hashbrown@0.14.5
	hermit-abi@0.3.9
	is-terminal@0.4.12
	itertools@0.10.5
	itoa@1.0.11
	js-sys@0.3.69
	keyvalues-parser@0.2.0
	libc@0.2.159
	libc@0.2.169
	libredox@0.1.3
	linux-raw-sys@0.4.14
	log@0.4.21
	memchr@2.7.4
	minimal-lexical@0.2.1
	miniz_oxide@0.8.0
	no-std-compat@0.4.1
	nom@7.1.3
	nom@8.0.0
	num-traits@0.2.18
	once_cell@1.19.0
	oorandom@11.1.3
	option-ext@0.2.0
	ordered-multimap@0.7.3
	pelite@0.10.0
	pelite-macros@0.1.1
	pest@2.7.10
	pest_derive@2.7.10
	pest_generator@2.7.10
	pest_meta@2.7.10
	plotters@0.3.5
	plotters-backend@0.3.5
	plotters-svg@0.3.5
	proc-macro2@1.0.81
	proc-macro2@1.0.93
	quote@1.0.36
	rayon@1.10.0
	rayon-core@1.12.1
	redox_users@0.5.0
	regex@1.10.4
	regex@1.11.1
	regex-automata@0.4.6
	regex-automata@0.4.8
	regex-syntax@0.8.3
	regex-syntax@0.8.5
	rust-ini@0.21.1
	rustix@0.38.37
	rustix@0.38.39
	rustix@0.38.40
	ryu@1.0.17
	same-file@1.0.6
	serde@1.0.199
	serde@1.0.200
	serde_derive@1.0.199
	serde_derive@1.0.200
	serde_json@1.0.116
	sha2@0.10.8
	syn@2.0.60
	syn@2.0.96
	tempfile@3.13.0
	tempfile@3.16.0
	tempfile@3.17.1
	thiserror@1.0.59
	thiserror@2.0.11
	thiserror-impl@1.0.59
	thiserror-impl@2.0.11
	tiny-keccak@2.0.2
	tinytemplate@1.2.1
	trim-in-place@0.1.7
	typenum@1.17.0
	ucd-trie@0.1.6
	unicase@2.7.0
	unicase@2.8.1
	unicode-ident@1.0.12
	version_check@0.9.4
	walkdir@2.5.0
	wasi@0.11.0+wasi-snapshot-preview1
	wasi@0.13.3+wasi-0.2.2
	wasm-bindgen@0.2.92
	wasm-bindgen-backend@0.2.92
	wasm-bindgen-macro@0.2.92
	wasm-bindgen-macro-support@0.2.92
	wasm-bindgen-shared@0.2.92
	web-sys@0.3.69
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.8
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows@0.59.0
	windows-core@0.59.0
	windows-implement@0.59.0
	windows-interface@0.59.0
	windows-result@0.3.0
	windows-strings@0.3.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-targets@0.52.6
	windows-targets@0.53.0
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.0
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.0
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.0
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.0
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.0
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.0
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.0
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.0
	wit-bindgen-rt@0.33.0
"

inherit cargo cmake

DESCRIPTION="A library for accessing LOOT's metadata and sorting functionality"
HOMEPAGE="https://github.com/loot/libloot"
SRC_URI="
	https://github.com/loot/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Ortham/esplugin/archive/refs/tags/${ESPLUGIN_PV}.tar.gz -> esplugin-${ESPLUGIN_PV}.tar.gz
	https://github.com/Ortham/libloadorder/archive/refs/tags/${LIBLOADORDER_PV}.tar.gz -> libloadorder-${LIBLOADORDER_PV}.tar.gz
	https://github.com/loot/loot-condition-interpreter/archive/refs/tags/${LCI_PV}.tar.gz -> loot-condition-interpreter-${LCI_PV}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	dev-libs/icu:=
	dev-cpp/tbb:=
	dev-libs/spdlog:=
	dev-libs/libfmt:=
	dev-cpp/yaml-cpp:=
"
DEPEND="
	${RDEPEND}
	dev-libs/boost
"
BDEPEND="
	>=dev-build/cmake-3.24
	dev-util/cbindgen
"

src_unpack() {
	cargo_src_unpack
}

src_configure() {
	cargo_src_configure

	local mycmakeargs=(
		-DLIBLOOT_BUILD_TESTS=OFF
		-DLIBLOOT_INSTALL_DOCS=OFF
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DESPLUGIN_URL="file://${DISTDIR}/esplugin-${ESPLUGIN_PV}.tar.gz"
		-DESPLUGIN_HASH="SHA256=8896859a6469e810c6e5430ed910fa8f8c31d39e032703b87ab090759663a240"
		-DLIBLOADORDER_URL="file://${DISTDIR}/libloadorder-${LIBLOADORDER_PV}.tar.gz"
		-DLIBLOADORDER_HASH="SHA256=5e4c12e91180abbf201be70b3073fce791bdee2d70f33f89b35942446d3b5782"
		-DLOOT_CONDITION_INTERPRETER_URL="file://${DISTDIR}/loot-condition-interpreter-${LCI_PV}.tar.gz"
		-DLOOT_CONDITION_INTERPRETER_HASH="SHA256=48db9d1022c65c6ea53b5febbbb8a45d089ac8e8773f8e14b069387fab80948d"
	)
	cmake_src_configure
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	cmake_src_compile
}

src_install() {
	cmake_src_install
}
