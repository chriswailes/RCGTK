# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/09
# Description: This file contains unit tests for the RCGTK::Function class.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/llvm'
require 'rcgtk/module'
require 'rcgtk/function'
require 'rcgtk/type'

class FunctionTester < Minitest::Test
	def setup
		@mod = RCGTK::Module.new('Testing Module')
		@fun = @mod.functions.add('testing_function', RCGTK::NativeIntType, [RCGTK::NativeIntType, RCGTK::NativeIntType])

		@fun.params[0].name = 'foo'
		@fun.params[1].name = 'bar'
	end

	def test_equality
		fun0 = @mod.functions.add('fun0', RCGTK::NativeIntType, [])
		fun1 = @mod.functions.add('fun0', RCGTK::FloatType, [])
		fun2 = RCGTK::Function.new(fun0.ptr)

		assert_equal(fun0, fun2)
		refute_equal(fun0, fun1)
	end

	def test_positive_index_in_range
		assert_equal('foo', @fun.params[0].name)
		assert_equal('bar', @fun.params[1].name)
	end

	def test_negative_index_in_range
		assert_equal('bar', @fun.params[-1].name)
		assert_equal('foo', @fun.params[-2].name)
	end

	def test_positive_index_out_of_range
		assert_nil(@fun.params[2])
	end

	def test_negative_index_out_of_range
		assert_nil(@fun.params[-3])
	end
end
