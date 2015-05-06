# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/03/08
# Description: This file adds some autoload features for the RCGTK submodules.

#######################
# Classes and Modules #
#######################

module RCGTK
	# This module contains classes and methods for code generation.  Code
	# generation functionality is provided by bindings to
	# [LLVM](http://llvm.org).
	module CG
		autoload :BasicBlock,      'rcgtk/basic_block'
		autoload :Bindings,        'rcgtk/bindings'
		autoload :Builder,         'rcgtk/builder'
		autoload :Context,         'rcgtk/context'
		autoload :ExecutionEngine, 'rcgtk/execution_engine'
		autoload :Function,        'rcgtk/function'
		autoload :GenericValue,    'rcgtk/generic_value'
		autoload :Instruction,     'rcgtk/instruction'
		autoload :LLVM,            'rcgtk/llvm'
		autoload :MemoryBuffer,    'rcgtk/memory_buffer'
		autoload :Module,          'rcgtk/module'
		autoload :PassManager,     'rcgtk/pass_manager'
		autoload :Support,         'rcgtk/support'
		autoload :Type,            'rcgtk/type'
		autoload :Value,           'rcgtk/value'
	end
end
