# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/11
# Description: This file contains unit tests for the mechanics beind
#              transformation passes.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/llvm'
require 'rcgtk/module'
require 'rcgtk/execution_engine'
require 'rcgtk/type'
require 'rcgtk/value'

class TransformTester < Minitest::Test
	def setup
		RCGTK::LLVM.init(:X86)

		@mod = RCGTK::Module.new('Testing Module')
		@jit = RCGTK::JITCompiler.new(@mod)
	end

	def test_gdce
		fn0 = @mod.functions.add('fn0', RCGTK::VoidType, []) do |fun|
			fun.linkage = :internal

			blocks.append do
				ret_void
			end
		end

		fn1 = @mod.functions.add('fn1', RCGTK::VoidType, []) do |fun|
			fun.linkage = :internal

			blocks.append do
				ret_void
			end
		end

		main = @mod.functions.add('main', RCGTK::VoidType, []) do
			blocks.append do
				call(fn0)
				ret_void
			end
		end

		funs = @mod.functions.to_a

		assert(funs.include?(fn0))
		assert(funs.include?(fn1))
		assert(funs.include?(main))

		@mod.pass_manager << :GDCE
		assert(@mod.pass_manager.run)

		funs = @mod.functions.to_a

		assert( funs.include?(fn0))
		assert(!funs.include?(fn1))
		assert( funs.include?(main))
	end
end
