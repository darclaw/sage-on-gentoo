# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

PYTHON_DEPEND="2:2.7"

inherit base eutils flag-o-matic multilib python scons-utils toolchain-funcs

DESCRIPTION="Polynomials over Boolean Rings"
HOMEPAGE="http://polybori.sourceforge.net/"

PSUFFIX=""
PVSUFFIX="${PSUFFIX/rc*/rc}"

SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}${PVSUFFIX}/${P}${PSUFFIX}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc gd"

# polybori does not have a working set of tests
RESTRICT="mirror test"

CDEPEND=">=dev-libs/boost-1.34.1[python]
	dev-python/ipython
	gd? ( media-libs/gd )"
DEPEND="${CDEPEND}
	>=sci-libs/m4ri-20090512
	doc? (
		dev-tex/tex4ht
		app-doc/doxygen
	)"
RDEPEND="${CDEPEND}"

USE_SCONS_TRUE="True"
USE_SCONS_FALSE="False"

PATCHES=(
	"${FILESDIR}"/gbcore.py.patch
	"${FILESDIR}"/ipbori.patch
	"${FILESDIR}"/nf.h.patch
	"${FILESDIR}"/${PN}-0.8.0-base-lookup.patch
)

pkg_setup() {
	python_set_active_version 2.7
	python_pkg_setup
	export DOT_SAGE="${S}"
}

src_prepare() {
	# make sure external m4ri is used
	rm -r M4RI || die "failed to remove internal copy of m4ri"

	base_src_prepare
}

src_compile(){
	# needed to make polybori linkable
	#append-flags -fPIC

	if [[ ${CHOST} == *-darwin* ]] ; then
		append-flags -fno-strict-aliasing
	fi

	# TODO: handle singular ?

	# store all parameters for scons in a bash array
	myesconsargs=(
		CC=$(tc-getCC)
		CXX=$(tc-getCXX)
		CFLAGS=${CFLAGS}
		CCFLAGS=""
		CXXFLAGS=${CXXFLAGS}
		LINKFLAGS=${LDFLAGS}
		HAVE_HEVEA=False
		HAVE_L2H=False
		$(use_scons doc HAVE_TEX4HT)
		$(use_scons doc HAVE_DOXYGEN)
		$(use_scons doc HAVE_PYDOC)
		MANDIR="${ED}"/usr/share/man
		PREFIX="${ED}"/usr
		DEVEL_LIB_PREFIX="${ED}"/usr/$(get_libdir)
		PYINSTALLPREFIX="${ED}"$(python_get_sitedir)
		INSTALLDIR="${ED}"/usr/share/polybori
		INSTALL_NAME_DIR="${EPREFIX}"/usr/$(get_libdir)/
		CONFFILE="${ED}"/usr/share/polybori/flags.conf
	)

	# extra configuration for macos
	# FIXME: don't know how to deal properly with versionned libraries with install_name so dropping it.
	if [[ ${CHOST} == *-darwin* ]] ; then
		myesconsargs+=(
			FORCE_HASH_MAP=True
			SHLIBVERSIONING=False
		)
	fi

	escons "${myesconsargs[@]}" prepare-install prepare-devel || die
}

src_install() {
	escons "${myesconsargs[@]}" install devel-install || die

	# remove incomplete documentation
	if ! use doc ; then
		rm -rf "${ED}"/usr/share/polybori/doc \
			|| die "failed to remove useless documentation"
	fi

	# we only need shared objects elsewhere
	rm "${ED}"/usr/$(get_libdir)/lib*.a \
		|| die "failed to remove static libraries"

	# fixing flags.conf
	sed -i "s:${D}:\/:" "${ED}"/usr/share/polybori/flags.conf || die
}
