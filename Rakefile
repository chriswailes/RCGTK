# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2015/05/05
# Description: This is RCGTK's Rakefile.

##############
# Rake Tasks #
##############

# Gems
require 'filigree/request_file'

# RCGTK
require File.expand_path("../lib/rcgtk/version", __FILE__)

###########
# Bundler #
###########

request_file('bundler', 'Bundler is not installed.') do
	Bundler::GemHelper.install_tasks
end

########
# Flay #
########

request_file('flay', 'Flay is not installed.') do
	desc 'Analyze code for similarities with Flay'
	task :flay do
		flay = Flay.new
		flay.process(*Dir['lib/**/*.rb'])
		flay.report
	end
end

########
# Flog #
########

request_file('flog_cli', 'Flog is not installed.') do
	desc 'Analyze code complexity with Flog'
	task :flog do
		whip = FlogCLI.new
		whip.flog('lib')
		whip.report
	end
end

############
# MiniTest #
############

request_file('rake/testtask', 'Minitest is not installed.') do
	Rake::TestTask.new do |t|
		t.libs << 'test'
		t.test_files = FileList['test/ts_rcgtk.rb']
	end
end

#########
# Notes #
#########

request_file('rake/notes/rake_task', 'Rake-notes is not installed.')

########
# Reek #
########

request_file('reek/rake/task', 'Reek is not installed.') do
	Reek::Rake::Task.new do |t|
	  t.fail_on_error = false
	end
end

##################
# Rubygems Tasks #
##################

request_file('rubygems/tasks', 'Rubygems-tasks is not installed.') do
	Gem::Tasks.new do |t|
		t.console.command = 'pry'
	end
end

########
# YARD #
########

request_file('yard', 'Yard is not installed.') do
	YARD::Rake::YardocTask.new do |t|
		yardlib = File.join(File.dirname(__FILE__), 'yardlib/rcgtk.rb')

		t.options	= [
			'-e',       yardlib,
			'--title',  'The Ruby Code Generation Toolkit',
			'-m',       'markdown',
			'-M',       'redcarpet',
			'--private'
		]

		t.files = Dir['lib/**/*.rb']
	end
end

##############
# RCGTK Tasks #
##############

desc 'Generate the bindings for LLVM.'
task :gen_bindings, :path do |t, args|
	require 'ffi_gen'

	# Generate the standard LLVM bindings.

	include_path = args[:path] ? args[:path] : 'llvm-c/'

	deprecated = [
		# BitReader.h
		'LLVMGetBitcodeModuleProviderInContext',
		'LLVMGetBitcodeModuleProvider',

		# BitWriter.h
		'LLVMWriteBitcodeToFileHandle',

		# Core.h
		'LLVMCreateFunctionPassManager',
		'LLVMStartMultithreaded',
		'LLVMStopMultithreaded',

		# ExectionEngine.h
		'LLVMCreateExecutionEngine',
		'LLVMCreateInterpreter',
		'LLVMCreateJITCompiler',
		'LLVMAddModuleProvider',
		'LLVMRemoveModuleProvider'
	]

	headers = [
		"#{include_path}/Core.h",

		"#{include_path}/Analysis.h",
		"#{include_path}/BitReader.h",
		"#{include_path}/BitWriter.h",
		"#{include_path}/Disassembler.h",
		"#{include_path}/Initialization.h",
		"#{include_path}/IRReader.h",
		"#{include_path}/Linker.h",
		"#{include_path}/LinkTimeOptimizer.h",
		"#{include_path}/Object.h",
		"#{include_path}/Support.h",
		"#{include_path}/Target.h",
		"#{include_path}/TargetMachine.h",

		# This must be listed after Target.h and TargetMachine.h due to a bug
		# with FFI-Gen.
		#
		# TODO: File an Issue with ffi-gen project.
		"#{include_path}/ExecutionEngine.h",

		"#{include_path}/Transforms/IPO.h",
		"#{include_path}/Transforms/PassManagerBuilder.h",
		"#{include_path}/Transforms/Scalar.h",
		"#{include_path}/Transforms/Vectorize.h"
	]

	FFIGen.generate(
		module_name: 'RCGTK::Bindings',
		ffi_lib:     "LLVM-#{RCGTK::LLVM_TARGET_VERSION}",
		headers:     headers,
		cflags:      `llvm-config --cflags`.split,
		prefixes:    ['LLVM'],
		blacklist:   deprecated,
		output:      "generated_bindings-#{RCGTK::LLVM_TARGET_VERSION}.rb"
	)
end

desc 'Find LLVM bindings with a regular expression.'
task :find_bind, :part do |t, args|

	# Get the task argument.
	part = Regexp.new(args[:part])

	# Require the Bindings module.
	require 'rcgtk/bindings'

	syms =
	Symbol.all_symbols.select do |sym|
		sym = sym.to_s.downcase

		sym[0..3] == 'llvm' and sym[4..-1] =~ part
	end.sort

	puts
	if not syms.empty?
		puts "Matching bindings [#{syms.length}]:"
		syms.each { |sym| puts "\t#{sym}" }

	else
		puts 'No matching bindings.'
	end
	puts
end
