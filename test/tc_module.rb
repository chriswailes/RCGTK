# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/04
# Description: This file contains unit tests for the RCGTK::Module class.

############
# Requires #
############

# Standard Library
require 'tempfile'

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/llvm'
require 'rcgtk/module'
require 'rcgtk/execution_engine'
require 'rcgtk/type'
require 'rcgtk/value'

#######################
# Classes and Modules #
#######################

class ModuleTester < Minitest::Test
	def setup
		RCGTK::LLVM.init(:X86)

		@mod = RCGTK::Module.new('Testing Module')
		@jit = RCGTK::JITCompiler.new(@mod)

		@mod.functions.add('int_function_tester', RCGTK::NativeIntType, []) do
			blocks.append { ret RCGTK::NativeInt.new(1) }
		end
	end

	def test_bitcode
		Tempfile.open('bitcode') do |tmp|
			assert(@mod.write_bitcode(tmp))

			new_mod = RCGTK::Module.read_bitcode(tmp.path)
			new_jit = RCGTK::JITCompiler.new(new_mod)

			assert_equal(1, new_jit.run_function(new_mod.functions['int_function_tester']).to_i)
		end
	end

	def test_equality
		mod0 = RCGTK::Module.new('foo')
		mod1 = RCGTK::Module.new('bar')
		mod2 = RCGTK::Module.new(mod0.ptr)

		assert_equal(mod0, mod2)
		refute_equal(mod0, mod1)
	end

	def test_external_fun
		fun = @mod.functions.add(:sin, RCGTK::DoubleType, [RCGTK::DoubleType])
		res = @jit.run_function(fun, RCGTK::GenericValue.new(1.0, RCGTK::DoubleType)).to_f(RCGTK::DoubleType)

		assert_in_delta(Math.sin(1.0), res, 1e-10)
	end

	def test_simple_int_fun
		assert_equal(1, @jit.run_function(@mod.functions['int_function_tester']).to_i)
	end

	def test_simple_float_fun
		fun = @mod.functions.add('float_function_tester', RCGTK::FloatType, []) do
			blocks.append do
				ret RCGTK::Float.new(1.5)
			end
		end

		assert_equal(1.5, @jit.run_function(fun).to_f(RCGTK::FloatType))
	end

	def test_simple_double_fun
		fun = @mod.functions.add('double_function_tester', RCGTK::DoubleType, []) do
			blocks.append do
				ret RCGTK::Double.new(1.6)
			end
		end

		assert_equal(1.6, @jit.run_function(fun).to_f(RCGTK::DoubleType))
	end
end
