# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/09
# Description: This file contains unit tests for the RCGTK::GenericValue class.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/generic_value'

class GenericValueTester < Minitest::Test
	def setup
		RCGTK::LLVM.init(:X86)
	end

	def test_integer
		assert_equal(2, RCGTK::GenericValue.new(2).to_i)
	end

	def test_float
		assert_in_delta(3.1415926, RCGTK::GenericValue.new(3.1415926).to_f, 1e-6)
	end

	def test_double
		assert_in_delta(3.1415926, RCGTK::GenericValue.new(3.1415926, RCGTK::DoubleType).to_f(RCGTK::DoubleType), 1e-6)
	end
end
