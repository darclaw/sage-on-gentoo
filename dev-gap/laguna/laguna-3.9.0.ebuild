# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Lie AlGebras and UNits of group Algebras"
HOMEPAGE="http://www.gap-system.org/Packages/${PN}.html"
GAP_VERSION="4.10.0"
SLOT="0/${GAP_VERSION}"
SRC_URI="https://www.gap-system.org/pub/gap/gap-$(ver_cut 1-2 ${GAP_VERSION})/tar.bz2/gap-${GAP_VERSION}.tar.bz2"

LICENSE="GPL-2+"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sci-mathematics/gap:${SLOT}
	dev-gap/GAPDoc:${SLOT}"

DOCS="ChangeLog README.md"

S="${WORKDIR}/gap-${GAP_VERSION}/pkg/${P}"

src_install(){
	default

	insinto /usr/share/gap/pkg/"${P}"
	doins -r doc lib
	doins *.g
}
