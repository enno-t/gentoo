# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
USE_RUBY="ruby31 ruby32 ruby33 ruby34"

RUBY_FAKEGEM_EXTRADOC="History.txt README.txt"

inherit ruby-fakegem

DESCRIPTION="Extends Rake with remote task goodness"
HOMEPAGE="https://github.com/seattlerb/rake-remote_task"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

ruby_add_bdepend "
	test? ( dev-ruby/minitest )"
ruby_add_rdepend ">=dev-ruby/open4-1.0 >=dev-ruby/rake-0.8 <dev-ruby/rake-15"

RDEPEND="net-misc/rsync"
DEPEND="test? ( net-misc/rsync )"

each_ruby_test() {
	${RUBY} -Ilib:. -e 'Dir["test/test_*.rb"].each{|f| require f}' || die
}
