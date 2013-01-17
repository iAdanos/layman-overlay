# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# github download taken from porticron ebuild

EAPI="4"
USE_RUBY="ruby18"
RUBY_S=chiliproject-${PN}-*
inherit eutils confutils depend.apache ruby-ng

DESCRIPTION="ChiliProject is a flexible project management web application
written using Ruby on Rails framework."
HOMEPAGE="http://www.chiliproject.org/"
SRC_URI="http://github.com/chiliproject/chiliproject/tarball/v${PV} ->
${P}.tar.gz"
#SRC_URI="mirror://github/chiliproject/chiliproject/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE="cvs darcs fastcgi git imagemagick mercurial mysql openid passenger postgres sqlite3 subversion startdate"

ruby_add_rdepend ">=dev-ruby/rake-0.8.7
	>=dev-ruby/rubygems-1.3.7
	>=dev-ruby/bundler-1.0.6
	>=dev-ruby/coderay-1.0.0
	<dev-ruby/coderay-1.1
	>=dev-ruby/i18n-0.4.2
	<dev-ruby/i18n-0.5
	>=dev-ruby/rdoc-2.4.2
	>=dev-ruby/liquid-2.3.0
	<dev-ruby/liquid-2.4
	dev-ruby/tzinfo
	>=dev-ruby/fastercsv-1.5.0
	>=dev-ruby/builder-2.1.2
	<dev-ruby/builder-2.2
	=dev-ruby/activesupport-2.3.14-r1
	"
# depend on activesupport-2.3.14-r1 to fix
# https://www.chiliproject.org/issues/529

ruby_add_rdepend ~dev-ruby/rails-2.3.14:2.3
#ruby_add_rdepend "dev-ruby/activerecord:2.3[mysql?,postgres?,sqlite3?]"
ruby_add_rdepend fastcgi dev-ruby/fcgi
ruby_add_rdepend imagemagick dev-ruby/rmagick
ruby_add_rdepend openid dev-ruby/ruby-openid

RDEPEND="${RDEPEND}
	passenger? ( >=dev-ruby/rack-1.1.0 www-apache/passenger )
	cvs? ( >=dev-vcs/cvs-1.12 )
	darcs? ( dev-vcs/darcs )
	git? ( dev-vcs/git )
	mercurial? ( dev-vcs/mercurial )
	subversion? ( >=dev-vcs/subversion-1.3 )"
	#dev-ruby/activerecord:2.3[mysql?,postgres?,sqlite3?]

CHILIPROJECT_DIR="/var/lib/${PN}"

pkg_setup() {
	confutils_require_any mysql postgres sqlite3
	enewgroup chiliproject
	# home directory is required for SCM.
	enewuser chiliproject -1 -1 "${CHILIPROJECT_DIR}" chiliproject
}

all_ruby_prepare() {
	rm -fr log files/delete.me
	echo "CONFIG_PROTECT=\"${CHILIPROJECT_DIR}/config\"" > "${T}/50${PN}"
	echo "CONFIG_PROTECT_MASK=\"${CHILIPROJECT_DIR}/config/locales\"" >> "${T}/50${PN}"

	if use startdate; then
				epatch "${FILESDIR}"/patch-startdate-2.0.0.diff
	fi
}

all_ruby_install() {
	dodoc -r doc/
	rm -fr doc

	insinto "${CHILIPROJECT_DIR}"
	doins -r .
	keepdir "${CHILIPROJECT_DIR}/files"
	keepdir "${CHILIPROJECT_DIR}/public/plugin_assets"

	keepdir /var/log/${PN}
	dosym /var/log/${PN}/ "${CHILIPROJECT_DIR}/log"

	fowners -R chiliproject:chiliproject \
		"${CHILIPROJECT_DIR}/config/environment.rb" \
		"${CHILIPROJECT_DIR}/files" \
		"${CHILIPROJECT_DIR}/public/plugin_assets" \
		"${CHILIPROJECT_DIR}/tmp" \
		/var/log/${PN}
	# for SCM
	fowners chiliproject:chiliproject "${CHILIPROJECT_DIR}"

	if use passenger ; then
		has_apache
		insinto "${APACHE_VHOSTS_CONFDIR}"
		doins "${FILESDIR}/10_chiliproject_vhost.conf"
	else
		newconfd "${FILESDIR}/${PN}.confd" ${PN}
		newinitd "${FILESDIR}/${PN}.initd" ${PN}
		keepdir /var/run/${PN}
		fowners -R chiliproject:chiliproject /var/run/${PN}
		dosym /var/run/${PN}/ "${CHILIPROJECT_DIR}/tmp/pids"
	fi
	doenvd "${T}/50${PN}"
}

pkg_postinst() {
	# run bundler
	local bundler_skip="test development"
	if ! use imagemagick ; then
		bundler_skip="${bundler_skip} rmagick"
	fi

	if ! use sqlite3 ; then
		bundler_skip="${bundler_skip} sqlite"
	fi

	if ! use postgres ; then
		bundler_skip="${bundler_skip} postgres"
	fi

	if ! use mysql ; then
		bundler_skip="${bundler_skip} mysql mysql2"
	fi

	if ! use openid ; then
		bundler_skip="${bundler_skip} openid"
	fi

	elog "running bundler: bundle install --without=${bundler_skip}"
	cd ${CHILIPROJECT_DIR}
	bundle install --without=${bundler_skip}

	einfo
	if [ -e "${ROOT}${CHILIPROJECT_DIR}/config/initializers/session_store.rb" ] ; then
		elog "Execute the following command to upgrade environment:"
		elog
		elog "# emerge --config =${CATEGORY}/${PF}"
		elog
		elog "For upgrade instructions take a look at:"
		elog "https://www.chiliproject.org/projects/chiliproject/wiki/Upgrade"
	else
		elog "Execute the following command to initialize environment:"
		elog
		elog "# cd ${CHILIPROJECT_DIR}"
		elog "# cp config/database.yml.example config/database.yml"
		elog "# \${EDITOR} config/database.yml"
		elog "# emerge --config =${CATEGORY}/${PF}"
		elog
		elog "Installation notes are at official site"
		elog "https://www.chiliproject.org/projects/chiliproject/wiki/Installation"
	fi

	einfo
}

pkg_config() {
	if [ ! -e "${CHILIPROJECT_DIR}/config/database.yml" ] ; then
		eerror "Copy ${CHILIPROJECT_DIR}/config/database.yml.example to ${CHILIPROJECT_DIR}/config/database.yml and edit this file in order to configure your database settings for \"production\" environment."
		die
	fi

	local RAILS_ENV=${RAILS_ENV:-production}
	local RUBY=${RUBY:-ruby18}

	cd "${CHILIPROJECT_DIR}"
	if [ -e "${CHILIPROJECT_DIR}/config/initializers/session_store.rb" ] ; then
		einfo
		einfo "Upgrade database."
		einfo

		einfo "Migrate database."
		RAILS_ENV="${RAILS_ENV}" bundle exec rake db:migrate
		einfo "Upgrade the plugin migrations."
		RAILS_ENV="${RAILS_ENV}" bundle exec rake db:migrate:upgrade_plugin_migrations
		RAILS_ENV="${RAILS_ENV}" bundle exec rake db:migrate_plugins
		einfo "Clear the cache and the existing sessions."
		RAILS_ENV="${RAILS_ENV}" bundle exec rake tmp:cache:clear
		RAILS_ENV="${RAILS_ENV}" bundle exec rake tmp:sessions:clear
	else
		einfo
		einfo "Initialize database."
		einfo

		einfo "Generate a session store secret."
		bundle exec rake generate_session_store
		einfo "Create the database structure."
		RAILS_ENV="${RAILS_ENV}" bundle exec rake db:migrate
		einfo "Insert default configuration data in database."
		RAILS_ENV="${RAILS_ENV}" bundle exec rake redmine:load_default_data
	fi

	if [ ! -e "${CHILIPROJECT_DIR}/config/configuration.yml" ] ; then
		ewarn
		ewarn "Copy ${CHILIPROJECT_DIR}/config/configuration.yml.example to
		${CHILIPROJECT_DIR}/config/configuration.yml and edit this file to adjust your SMTP settings."
		ewarn
	fi
}
