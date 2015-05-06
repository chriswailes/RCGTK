# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2015/05/05
# Description: This is RCGTK's Gem specification.

require File.expand_path("../lib/rcgtk/version", __FILE__)

Gem::Specification.new do |s|
	s.platform = Gem::Platform::RUBY

	s.name        = 'rcgtk'
	s.version     = RCGTK::VERSION
	s.summary     = 'The Ruby Code Generation Toolkit'
	s.description =
		'The Ruby Code Generation Toolkit provides classes for generating LLVM IR and native object code.'

	s.files = [
		'LICENSE',
		'AUTHORS',
		'README.md',
		'Rakefile',
	] +
	Dir.glob('lib/**/*.rb')

	s.test_files = Dir['test/**/**.rb']

	s.require_path	= 'lib'

	s.author   = 'Chris Wailes'
	s.email    = 'chris.wailes+rcgtk@gmail.com'
	s.homepage = 'https://github.com/chriswailes/RCGTK'
	s.license  = 'University of Illinois/NCSA Open Source License'

	s.required_ruby_version = '>= 2.0.0'

	################
	# Dependencies #
	################

	s.add_runtime_dependency('ffi', '~> 1.0', '>= 1.0.0')
	s.add_runtime_dependency('filigree', '~> 0.3', '>= 0.3.3')

	############################
	# Development Dependencies #
	############################

	s.add_development_dependency('bundler', '~> 0')
	s.add_development_dependency('ffi_gen', '~> 1.1', '>= 1.1.0')
	s.add_development_dependency('flay', '~> 0')
	s.add_development_dependency('flog', '~> 0')
	s.add_development_dependency('minitest', '~> 0')
	s.add_development_dependency('pry', '~> 0')
	s.add_development_dependency('rake', '~> 0')
	s.add_development_dependency('rake-notes', '~> 0')
	s.add_development_dependency('reek', '~> 0')
	s.add_development_dependency('rubygems-tasks', '~> 0')
	s.add_development_dependency('simplecov', '~> 0')
	s.add_development_dependency('yard', '~> 0.8', '>= 0.8.1')
end
