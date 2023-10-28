# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop rpm systemd shell-completion

DESCRIPTION="Tool used to manage daemon setup"
HOMEPAGE="https://github.com/mullvad/mullvadvpn-app https://mullvad.net/"
SRC_URI="amd64? ( https://github.com/mullvad/mullvadvpn-app/releases/download/${PV}/MullvadVPN-${PV}_x86_64.rpm )"

LICENSE="GPL-3"
SLOT="0"
RESTRICT="test strip"
KEYWORDS="-* ~amd64"

QA_PREBUILT="*"

S="${WORKDIR}"

src_install() {
	# Using doins -r would strip executable bits from all binaries
	cp -pPR "${S}"/opt "${D}"/ || die "Failed to copy files"
	fperms +x "/opt/Mullvad VPN/chrome_crashpad_handler"
	fperms 4755 "/opt/Mullvad VPN/chrome-sandbox"

	# tbh I don't know if all next lines are needed or we can just do cp -pPR "${S}"/usr "${D}"/" 

	local i
	dobin "${S}"/usr/bin/mullvad
	dobin "${S}"/usr/bin/mullvad-daemon
	dobin "${S}"/usr/bin/mullvad-exclude
	dosym "/opt/Mullvad VPN/resources/mullvad-problem-report" /usr/bin/mullvad-problem-report

	systemd_newunit "${S}"/usr/lib/systemd/system/mullvad-daemon.service mullvad-daemon.service
	systemd_newunit "${S}"/usr/lib/systemd/system/mullvad-early-boot-blocking.service mullvad-early-boot-blocking.service

	newbashcomp "${S}"/usr/share/bash-completion/completions/mullvad mullvad
	newfishcomp "${S}"/usr/share/fish/vendor_completions.d/mullvad.fish mullvad
	newzshcomp "${S}"/usr/share/zsh/site-functions/_mullvad _mullvad

	domenu "${S}"/usr/share/applications/mullvad-vpn.desktop
	local x
	for x in 16 32 48 64 128 256 512 1024; do
		doicon -s ${x} ${S}/usr/share/icons/hicolor/${x}x${x}/apps/mullvad-vpn.png
	done

}
