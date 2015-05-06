# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/13
# Description: This file contains unit tests for the RCGTK::BasicBlock
#              class.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/llvm'
require 'rcgtk/module'

class BasicBlockTester < Minitest::Test
	def setup
		RCGTK::LLVM.init(:X86)

		@mod = RCGTK::Module.new('Testing Module')
	end

	def test_basic_block
		fun = @mod.functions.add('basic_block_tester', RCGTK::VoidType, [])
		bb0 = fun.blocks.append
		bb1 = fun.blocks.append

		assert_equal(fun, bb0.parent)
		assert_equal(fun, bb1.parent)

		assert_equal(bb1, bb0.next)
		assert_equal(bb0, bb1.previous)

		bb0.build { br(bb1) }
		bb1.build { ret_void }

		assert_equal(bb0.instructions.first, bb0.instructions.last)
		assert_equal(bb1.instructions.first, bb1.instructions.last)
	end

	def test_basic_block_collection
		fun = @mod.functions.add('basic_block_collection_tester', RCGTK::VoidType, [])
		bb0 = fun.blocks.append

		assert_instance_of(RCGTK::BasicBlock, bb0)

		assert_equal(1, fun.blocks.size)
		assert_equal(fun.blocks.first, fun.blocks.last)
		assert_equal(fun.blocks.first, fun.blocks.entry)

		bb1 = fun.blocks.append

		assert_equal(2, fun.blocks.size)
		assert_equal(bb0, fun.blocks.first)
		assert_equal(bb1, fun.blocks.last)

		[fun.blocks.each.to_a, fun.blocks.to_a].each do |blocks|
			assert_equal(2, blocks.size)
			assert_equal(bb0, blocks[0])
			assert_equal(bb1, blocks[1])
		end
	end

	def test_basic_block_enumeration
		fun = @mod.functions.add('basic_block_enumeration_tester', RCGTK::DoubleType, [RCGTK::DoubleType])
		bb0 = fun.blocks.append

		[bb0.instructions.each.to_a, bb0.instructions.to_a].each do |insts|
			assert_equal(0, insts.size)
		end

		bb0.build { ret(fadd(fun.params[0], RCGTK::Double.new(1.0))) }

		[bb0.instructions.each.to_a, bb0.instructions.to_a].each do |insts|
			assert_equal(2, insts.size)

			assert_equal(bb0.instructions.first, insts[0])
			assert_equal(bb0.instructions.last,  insts[1])
		end
	end
end
