# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="readline,sqlite"

# disable parallel build - Sage has its own method (see src_configure)
DISTUTILS_NO_PARALLEL_BUILD="1"

inherit distutils-r1 eutils flag-o-matic multilib multiprocessing prefix toolchain-funcs versionator

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="git://github.com/sagemath/sage.git"
	EGIT_BRANCH=develop
	EGIT_SOURCEDIR="${WORKDIR}/${P}"
	inherit git-2
	KEYWORDS=""
else
	SRC_URI="mirror://sagemath/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-macos"
fi

DESCRIPTION="Math software for algebra, geometry, number theory, cryptography and numerical computation"
HOMEPAGE="http://www.sagemath.org"
SRC_URI="${SRC_URI}
	mirror://sagemath/patches/${PN}-6.3-neutering.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
IUSE="latex testsuite lrs nauty debug"

RESTRICT="mirror test"

CDEPEND="dev-libs/gmp
	>=dev-libs/mpfr-3.1.0
	>=dev-libs/mpc-1.0
	>=dev-libs/ntl-6.0.0
	>=sci-libs/sage-ppl-1.0
	>=dev-lisp/ecls-12.12.1-r5
	>=dev-python/numpy-1.8.1[${PYTHON_USEDEP}]
	>=dev-python/cython-0.21[${PYTHON_USEDEP}]
	>=sci-mathematics/eclib-20140805[flint]
	>=sci-mathematics/gmp-ecm-6.4.4[-openmp]
	>=sci-mathematics/flint-2.4.2[ntl]
	~sci-libs/fplll-4.0.4
	~sci-libs/givaro-3.7.1
	>=sci-libs/gsl-1.15
	>=sci-libs/iml-1.0.1
	~sci-libs/libcliquer-1.21_p1
	~sci-libs/libgap-4.7.4
	~sci-libs/linbox-1.3.2[sage]
	~sci-libs/m4ri-20140914
	~sci-libs/m4rie-20140914
	>=sci-libs/mpfi-1.5.1
	~sci-libs/pynac-0.3.2[${PYTHON_USEDEP}]
	>=sci-libs/symmetrica-2.0-r3
	>=sci-libs/zn_poly-0.9
	sci-mathematics/glpk:0=
	>=sci-mathematics/lcalc-1.23-r6[pari]
	>=sci-mathematics/lrcalc-1.1.6_beta1
	=sci-mathematics/pari-2.7.1[data,gmp]
	>=sci-mathematics/polybori-0.8.3[${PYTHON_USEDEP}]
	>=sci-mathematics/ratpoints-2.1.3
	~sci-mathematics/sage-baselayout-${PV}[testsuite=,${PYTHON_USEDEP}]
	~sci-mathematics/sage-clib-${PV}
	~sci-libs/libsingular-3.1.6[flint]
	media-libs/gd[jpeg,png]
	media-libs/libpng:0=
	>=sys-libs/readline-6.2
	sys-libs/zlib
	dev-python/python-pkgconfig
	virtual/cblas
	!sci-mathematics/sage-extcode
	!sci-mathematics/sage-matroids"

DEPEND="${CDEPEND}
	!dev-python/gmpy"

RDEPEND="${CDEPEND}
	>=dev-lang/R-3.1.0
	>=dev-python/cvxopt-1.1.7[glpk,${PYTHON_USEDEP}]
	>=dev-python/gdmodule-0.56-r2[png,${PYTHON_USEDEP}]
	~dev-python/ipython-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/jinja-2.5.5[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-1.3.1[${PYTHON_USEDEP}]
	<dev-python/matplotlib-1.4.0[${PYTHON_USEDEP}]
	>=dev-python/mpmath-0.18[${PYTHON_USEDEP}]
	>=dev-python/networkx-1.8[${PYTHON_USEDEP}]
	~dev-python/sage-pexpect-2.0[${PYTHON_USEDEP}]
	>=dev-python/pycrypto-2.1.0[${PYTHON_USEDEP}]
	>=dev-python/rpy-2.3.8[${PYTHON_USEDEP}]
	>=dev-python/sphinx-1.1.2[${PYTHON_USEDEP}]
	>=dev-python/sqlalchemy-0.5.8[${PYTHON_USEDEP}]
	>=dev-python/sympy-0.7.4[${PYTHON_USEDEP}]
	>=media-gfx/tachyon-0.98.9[png]
	>=sci-libs/cddlib-094f-r2
	>=sci-libs/scipy-0.14.0[${PYTHON_USEDEP}]
	>=sci-mathematics/flintqs-20070817
	~sci-mathematics/gap-4.7.4
	>=sci-mathematics/genus2reduction-20140211
	~sci-mathematics/gfan-0.5
	>=sci-mathematics/cu2-20060223
	>=sci-mathematics/cubex-20060128
	>=sci-mathematics/dikcube-20070912
	>=sci-mathematics/maxima-5.34.1-r1[ecls]
	>=sci-mathematics/mcube-20051209
	>=sci-mathematics/optimal-20040603
	>=sci-mathematics/palp-2.1
	~sci-mathematics/sage-data-elliptic_curves-0.7
	~sci-mathematics/sage-data-graphs-20120404
	~sci-mathematics/sage-data-combinatorial_designs-20140630
	~sci-mathematics/sage-data-polytopes_db-20120220
	~sci-mathematics/singular-3.1.6
	>=sci-mathematics/sympow-1.018.1
	!prefix? ( >=sys-libs/glibc-2.13-r4 )
	latex? (
		~dev-tex/sage-latex-2.3.4
		|| ( app-text/dvipng[truetype] media-gfx/imagemagick[png] )
	)
	lrs? ( sci-libs/lrslib )
	nauty? ( sci-mathematics/nauty )"

PDEPEND="~sci-mathematics/sage-notebook-0.10.8.2[${PYTHON_USEDEP}]
	~sci-mathematics/sage-data-conway_polynomials-0.4
	~sci-mathematics/sage-doc-${PV}
	testsuite? ( ~sci-mathematics/sage-doc-${PV}[html] )"

S="${WORKDIR}/${P}/src"

pkg_setup() {
	# needed since Ticket #14460
	tc-export CC
}

python_prepare() {
	# ATLAS independence
	epatch "${FILESDIR}"/${PN}-6.4-blas.patch

	# Remove sage's package management system
	epatch "${WORKDIR}"/patches/${PN}-6.3-package.patch
	rm sage/misc/package.py

	# Remove sage's git capabilities
	epatch "${WORKDIR}"/patches/${PN}-6.2-hg.patch
	rm -rf sage/dev

	# Remove sage cmdline tests related to these
	epatch "${WORKDIR}"/patches/${PN}-6.0-cmdline.patch

	if use lrs; then
		sed -i "s:if True:if False:" sage/geometry/polyhedron/base.py
	fi

	if use nauty; then
		sed -i "s:if True:if False:" \
			sage/graphs/graph_generators.py \
			sage/graphs/digraph_generators.py \
			sage/graphs/hypergraph_generators.py
	fi

	# replace pexpect with sage pinned version
	epatch "${FILESDIR}"/${PN}-6.2-pexpect.patch
	sed -i "s:import pexpect:import sage_pexpect as pexpect:g" \
		`grep -rl "import pexpect" *`
	sed -i "s:from pexpect:from sage_pexpect:g" \
		`grep -rl "from pexpect" *`

	############################################################################
	# Fixes to Sage's build system
	############################################################################

	# use already installed csage
	rm -rf c_lib || die "failed to remove c library directory"

	# fix png library name
	sed -i "s:png12:$(libpng-config --libs | cut -dl -f2):g" module_list.py

	# fix numpy path (final quote removed to catch numpy_include_dirs and numpy_depends)
	sed -i "s:SAGE_LOCAL + '/lib/python/site-packages/numpy/core/include:'$(python_get_sitedir)/numpy/core/include:g" \
		module_list.py

	# use sage-ppl
	epatch "${FILESDIR}"/${PN}-6.4-ppl1.patch
	sed -i "s:lib/ppl1:$(get_libdir)/ppl1:" module_list.py

	# fix lcalc path
	sed -i "s:SAGE_INC + \"/libLfunction:SAGE_INC + \"/Lfunction:g" module_list.py

	# We add -DNDEBUG to objects linking to givaro and libsingular And use factory headers from libsingular.
	epatch "${FILESDIR}"/${PN}-6.4-givaro_singular_extra.patch

	# Do not clean up the previous install with setup.py
	epatch "${FILESDIR}"/${PN}-6.3-noclean.patch

	############################################################################
	# Fixes to Sage itself
	############################################################################

	# sage on gentoo env.py
	epatch "${FILESDIR}"/sage-6.3-env.patch
	eprefixify sage/env.py

	# fix library path of libsingular
	sed -i "s:os.environ\['SAGE_LOCAL'\]+\"/lib:\"${EPREFIX}/usr/$(get_libdir):" \
		sage/libs/singular/singular.pyx

	# TODO: should be a patch
	# run maxima with ecl
	sed -i "s:'maxima :'maxima -l ecl :g" \
		sage/interfaces/maxima.py \
		sage/interfaces/maxima_abstract.py

	# speaking of ecl - patching so we can allow ecl with unicode.
	epatch "${FILESDIR}"/trac_14636_1.patch
	epatch "${FILESDIR}"/trac_14636_2b.patch

	# TODO: should be a patch
	# Uses singular internal copy of the factory header
	sed -i "s:factory/factory.h:singular/factory.h:" \
		sage/libs/singular/singular-cdefs.pxi

	# finding JmolData.jar in the right place
	sed -i "s:\"jmol\", \"JmolData:\"jmol-applet\", \"JmolData:" sage/interfaces/jmoldata.py

	# Make sage-inline-fortran useless by having better fortran settings
	sed -i \
		-e "s:--f77exec=sage-inline-fortran:--f77exec=$(tc-getF77):g" \
		-e "s:--f90exec=sage-inline-fortran:--f90exec=$(tc-getFC):g" \
		sage/misc/inline_fortran.py

	# TODO: should be a patch
	# patch lie library path
	sed -i -e "s:/lib/LiE/:/share/lie/:" sage/interfaces/lie.py

	# patching libs/gap/util.pyx so we don't get noise from missing SAGE_LOCAL/gap/latest
	epatch "${FILESDIR}"/${PN}-5.9-libgap.patch

	# TODO: should be a patch
	# Getting the singular documentation from the right place
	sed -i "s:os.environ\[\"SAGE_LOCAL\"\]+\"/share/singular/\":sage.env.SAGE_DOC + \"/\":" \
		sage/interfaces/singular.py

	# Fix for sphinx 1.2+
	epatch "${FILESDIR}"/${PN}-doc-6.2-seealso.patch

	# Make the Octave interface work with a root install
	# some other interface are likely to be affected
	sed -i "s:script_subdirectory='user':script_subdirectory=None:" \
		sage/interfaces/octave.py

	############################################################################
	# Fixes to doctests
	############################################################################

	# TODO: should be a patch
	# remove 'local' part
	sed -i "s:\.\.\./local/share/pari:.../share/pari:g" sage/interfaces/gp.py

	# fix all.py
	epatch "${FILESDIR}"/${PN}-6.0-all.py.patch
	sed -i \
		-e "s:\"lib\",\"python\":\"$(get_libdir)\",\"${EPYTHON}\":" \
		-e "s:\"bin\":\"lib\",\"python-exec\",\"${EPYTHON}\":" sage/all.py

	# do not test safe python stuff from trac 13579
	epatch "${FILESDIR}"/${PN}-6.0-safepython.patch

	# remove version information of GLPK
	epatch "${FILESDIR}"/${PN}-5.9-fix-mip-doctest.patch

	# 'sage' is not in SAGE_ROOT, but in PATH
	epatch "${FILESDIR}"/${PN}-5.9-fix-ostools-doctest.patch

	# change the location of the doc building tools in sage/doctest/control.py
	epatch "${FILESDIR}"/${PN}-6.3-doc_common.patch

	# fix location of the html doc
	epatch "${FILESDIR}"/${PN}-6.0-sagedoc.patch
}

python_configure() {
	export SAGE_LOCAL="${EPREFIX}"/usr/
	export SAGE_ROOT="${EPREFIX}"/usr/share/sage
	export SAGE_SRC=`pwd`
	export SAGE_VERSION=${PV}
	export SAGE_NUM_THREADS=$(makeopts_jobs)
	if use debug; then
		export SAGE_DEBUG=1
	fi

	# files are not built unless they are touched
	find sage -name "*pyx" -exec touch '{}' \; \
		|| die "failed to touch *pyx files"
}

python_install_all() {
	distutils-r1_python_install_all

	# install sources needed for testing/compiling of cython/spyx files
	find sage ! \( -name "*.py" -o -name "*.pyx" -o -name "*.pxd" -o \
		-name "*.pxi" -o -name "*.h" \
		-o -name "*matrix_rational_dense_linbox.cpp" \
		-o -name "*wrap.cc" \
		-o -name "*.rst" \) -type f -delete \
		|| die "failed to remove non-testable sources"

	insinto /usr/share/sage/src
	doins -r sage
	if use debug; then
		pushd build
		doins -r cython_debug
		popd
	fi
}

pkg_postinst() {
	einfo "If you use Sage's browser interface ('Sage Notebook') and experience"
	einfo "an 'Internal Server Error' you should append the following line to"
	einfo "your ~/.bashrc (replace firefox with your favorite browser and note"
	einfo "that in your case it WILL NOT WORK with xdg-open):"
	einfo ""
	einfo "  export SAGE_BROWSER=/usr/bin/firefox"
	einfo ""

	einfo "Vanilla Sage comes with the 'Standard' set of Sage Packages, i.e."
	einfo "those listed at: http://sagemath.org/packages/standard/ which are"
	einfo "installed now."
	einfo "There are also some packages of the 'Optional' set (which consists"
	einfo "of the these: http://sagemath.org/packages/optional/) available"
	einfo "which may be installed with portage as usual."

	if use testsuite ; then

	einfo ""
	einfo "To test Sage with 4 parallel processes run the following command:"
	einfo ""
	einfo "  sage -tp 4 --all"
	einfo ""
	einfo "Note that testing Sage may take more than an hour depending on your"
	einfo "processor(s). You _will_ see failures but many of them are harmless"
	einfo "such as version mismatches and numerical noise. Since Sage is"
	einfo "changing constantly we do not maintain an up-to-date list of known"
	einfo "failures."

	fi

	einfo ""
	einfo "IF YOU EXPERIENCE PROBLEMS and wish to report them please use the"
	einfo "overlay's issue tracker at"
	einfo ""
	einfo "  https://github.com/cschwan/sage-on-gentoo/issues"
	einfo ""
	einfo "There we can react faster than on bugs.gentoo.org where bugs first"
	einfo "need to be assigned to the right person. Thank you!"
}
