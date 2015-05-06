# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/09
# Description: This file contains unit tests for the RCGTK::Type class and
#              its subclasses.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/type'

class TypeTester < Minitest::Test
	def setup
		@pointee = RCGTK::NativeIntType.instance
		@pointer = RCGTK::PointerType.new(@pointee)
	end

	def test_deferrent_element_type_stuct_type
		type = RCGTK::StructType.new([], 'test_struct')
		type.element_types = [RCGTK::NativeIntType, RCGTK::FloatType]

		assert_equal(2, type.element_types.size)
		assert_equal(RCGTK::NativeIntType.instance, type.element_types[0])
		assert_equal(RCGTK::FloatType.instance, type.element_types[1])

	end

	def test_element_type
		assert_equal(@pointee, @pointer.element_type)
	end

	def test_equality
		assert_equal(RCGTK::NativeIntType, RCGTK::NativeIntType)
		refute_equal(RCGTK::NativeIntType, RCGTK::FloatType)

		at0 = RCGTK::ArrayType.new(RCGTK::NativeIntType, 2)
		at1 = RCGTK::ArrayType.new(RCGTK::NativeIntType, 2)
		at2 = RCGTK::ArrayType.new(RCGTK::FloatType, 2)

		assert_equal(at0, at1)
		refute_equal(at0, at2)
	end

	def test_kind
		assert_equal(:pointer, @pointer.kind)
		assert_equal(:integer, @pointee.kind)
	end

	def test_named_struct_type
		type = RCGTK::StructType.new([RCGTK::NativeIntType, RCGTK::FloatType], 'test_struct')

		assert_instance_of(RCGTK::StructType, type)
		assert_equal('test_struct', type.name)
	end

	def test_simple_struct_type
		type = RCGTK::StructType.new([RCGTK::NativeIntType, RCGTK::FloatType])

		assert_instance_of(RCGTK::StructType, type)
		assert_equal(2, type.element_types.size)
		assert_equal(RCGTK::NativeIntType.instance, type.element_types[0])
		assert_equal(RCGTK::FloatType.instance, type.element_types[1])
	end
end
