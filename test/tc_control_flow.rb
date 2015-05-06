# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/09
# Description: This file contains unit tests for control flow instructions.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/llvm'
require 'rcgtk/execution_engine'
require 'rcgtk/module'
require 'rcgtk/function'
require 'rcgtk/type'

class ControlFlowTester < Minitest::Test
	def setup
		RCGTK::LLVM.init(:X86)

		@mod = RCGTK::Module.new('Testing Module')
		@jit = RCGTK::JITCompiler.new(@mod)
	end

	##############
	# Call Tests #
	##############

	def test_external_call
		extern = @mod.functions.add('abs', RCGTK::NativeIntType, [RCGTK::NativeIntType])

		fun = @mod.functions.add('external_call_tester', RCGTK::NativeIntType, [RCGTK::NativeIntType]) do |fun|
			blocks.append { ret call(extern, fun.params[0]) }
		end

		assert_equal(10, @jit.run_function(fun, -10).to_i)
	end

	def test_external_string_call
		global = @mod.globals.add(RCGTK::ArrayType.new(RCGTK::Int8Type, 5), "path")
		global.linkage = :internal
		global.initializer = RCGTK::ConstantString.new('PATH')

		external = @mod.functions.add('getenv', RCGTK::PointerType.new(RCGTK::Int8Type), [RCGTK::PointerType.new(RCGTK::Int8Type)])

		fun = @mod.functions.add('external_string_call_tester', RCGTK::PointerType.new(RCGTK::Int8Type), []) do
			blocks.append do
				param = gep(global, [RCGTK::NativeInt.new(0), RCGTK::NativeInt.new(0)])

				ret call(external, param)
			end
		end

		assert_equal(ENV['PATH'], @jit.run_function(fun).ptr.read_pointer.read_string)
	end

	def test_nested_call
		fun0 = @mod.functions.add('simple_call_tester0', RCGTK::NativeIntType, []) do
			blocks.append { ret RCGTK::NativeInt.new(1) }
		end

		fun1 = @mod.functions.add('simple_call_tester1', RCGTK::NativeIntType, []) do
			blocks.append { ret call(fun0) }
		end

		assert_equal(1, @jit.run_function(fun1).to_i)
	end

	def test_recursive_call
		fun = @mod.functions.add('recursive_call_tester', RCGTK::NativeIntType, [RCGTK::NativeIntType]) do |fun|
			entry	= blocks.append
			recurse	= blocks.append
			exit		= blocks.append

			entry.build do
				cond(icmp(:uge, fun.params[0], RCGTK::NativeInt.new(5)), exit, recurse)
			end

			result =
			recurse.build do
				call(fun, add(fun.params[0], RCGTK::NativeInt.new(1))).tap { br exit }
			end

			exit.build do
				ret(phi(RCGTK::NativeIntType, {entry => fun.params[0], recurse => result}))
			end
		end

		assert_equal(5, @jit.run_function(fun, 1).to_i)
		assert_equal(6, @jit.run_function(fun, 6).to_i)
	end

	##############
	# Jump Tests #
	##############

	def test_cond_jump
		fun = @mod.functions.add('direct_jump_tester', RCGTK::NativeIntType, []) do |fun|
			entry = blocks.append

			bb0 = blocks.append { ret RCGTK::NativeInt.new(1) }
			bb1 = blocks.append { ret RCGTK::NativeInt.new(0) }

			entry.build do
				cond(icmp(:eq, RCGTK::NativeInt.new(1), RCGTK::NativeInt.new(2)), bb0, bb1)
			end
		end

		assert_equal(0, @jit.run_function(fun).to_i)
	end

	def test_direct_jump
		fun = @mod.functions.add('direct_jump_tester', RCGTK::NativeIntType, []) do |fun|
			entry = blocks.append

			bb0 = blocks.append { ret(RCGTK::NativeInt.new(1)) }
			bb1 = blocks.append { ret(RCGTK::NativeInt.new(0)) }

			entry.build { br bb1 }
		end

		assert_equal(0, @jit.run_function(fun).to_i)
	end

	def test_switched_jump
		fun = @mod.functions.add('direct_jump_tester', RCGTK::NativeIntType, []) do |fun|
			entry = blocks.append

			bb0 = blocks.append { ret RCGTK::NativeInt.new(1) }
			bb1 = blocks.append { ret RCGTK::NativeInt.new(0) }

			entry.build do
				switch(RCGTK::NativeInt.new(1), bb0, {RCGTK::NativeInt.new(1) => bb1})
			end
		end

		assert_equal(0, @jit.run_function(fun).to_i)
	end

	##############
	# Misc Tests #
	##############

	def test_select
		fun = @mod.functions.add('select_tester', RCGTK::Int1Type, [RCGTK::NativeIntType]) do |fun|
			blocks.append do
				ret select(fun.params[0], RCGTK::Int1.new(0), RCGTK::Int1.new(1))
			end
		end

		assert_equal(0, @jit.run_function(fun, 1).to_i(false))
		assert_equal(1, @jit.run_function(fun, 0).to_i(false))
	end

	#############
	# Phi Tests #
	#############

	def test_phi
		fun = @mod.functions.add('phi_tester', RCGTK::NativeIntType, [RCGTK::NativeIntType]) do |fun|
			entry	= blocks.append('entry')
			block0	= blocks.append('block0')
			block1	= blocks.append('block1')
			exit		= blocks.append('exit')

			entry.build do
				cond(icmp(:eq, fun.params[0], RCGTK::NativeInt.new(0)), block0, block1)
			end

			result0 =
			block0.build do
				add(fun.params[0], RCGTK::NativeInt.new(1)).tap { br(exit) }
			end

			result1 =
			block1.build do
				sub(fun.params[0], RCGTK::NativeInt.new(1)).tap { br(exit) }
			end

			exit.build do
				ret(phi(RCGTK::NativeIntType, {block0 => result0, block1 => result1}))
			end
		end

		assert_equal(1, @jit.run_function(fun, 0).to_i)
		assert_equal(0, @jit.run_function(fun, 1).to_i)
	end
end
