# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/09
# Description: This file contains unit tests for the RCGTK::Value class and
#              its subclasses.

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

class ValueTester < Minitest::Test
	def setup
		RCGTK::LLVM.init(:X86)

		@mod = RCGTK::Module.new('Testing Module')
		@jit = RCGTK::JITCompiler.new(@mod)
	end

	def test_array_values
		fun = @mod.functions.add('array_function_tester', RCGTK::NativeIntType,
		                         [RCGTK::NativeIntType, RCGTK::NativeIntType]) do |fun|

			blocks.append do
				ptr = alloca(RCGTK::ArrayType.new(RCGTK::NativeIntType, 2))

				array = load(ptr)
				array = insert_value(array, fun.params[0], 0)
				array = insert_value(array, fun.params[1], 1)

				ret(add(extract_value(array, 0), extract_value(array, 1)))
			end
		end

		assert_equal(5, @jit.run_function(fun, 2, 3).to_i)
	end

	def test_constant_array_from_array
		array = RCGTK::ConstantArray.new(RCGTK::NativeIntType, [RCGTK::NativeInt.new(0), RCGTK::NativeInt.new(1)])

		assert_instance_of(RCGTK::ConstantArray, array)
		assert_equal(2, array.length)
	end

	def test_constant_array_from_size
		array = RCGTK::ConstantArray.new(RCGTK::NativeIntType, 2) { |i| RCGTK::NativeInt.new(i) }

		assert_instance_of(RCGTK::ConstantArray, array)
		assert_equal(2, array.length)
	end

	def test_constant_vector_elements
		fun = @mod.functions.add('constant_vector_elements_tester', RCGTK::NativeIntType,
		                         [RCGTK::NativeIntType, RCGTK::NativeIntType]) do |fun|

			blocks.append do
				ptr = alloca(RCGTK::VectorType.new(RCGTK::NativeIntType, 2))

				vector = load(ptr)
				vector = insert_element(vector, fun.params[0], RCGTK::NativeInt.new(0))
				vector = insert_element(vector, fun.params[1], RCGTK::NativeInt.new(1))

				ret(add(extract_element(vector, RCGTK::NativeInt.new(0)), extract_element(vector, RCGTK::NativeInt.new(1))))
			end
		end

		assert_equal(5, @jit.run_function(fun, 2, 3).to_i)
	end

	def test_constant_vector_from_array
		vector = RCGTK::ConstantVector.new([RCGTK::NativeInt.new(0), RCGTK::NativeInt.new(1)])

		assert_instance_of(RCGTK::ConstantVector, vector)
		assert_equal(2, vector.size)
	end

	def test_constant_vector_from_size
		vector = RCGTK::ConstantVector.new(2) { |i| RCGTK::NativeInt.new(i) }

		assert_instance_of(RCGTK::ConstantVector, vector)
		assert_equal(2, vector.size)
	end

	def test_constant_vector_shuffle
		fun = @mod.functions.add('constant_vector_shuffle_tester', RCGTK::NativeIntType, Array.new(4, RCGTK::NativeIntType)) do |fun|
			blocks.append do
				vec_type = RCGTK::VectorType.new(RCGTK::NativeIntType, 2)

				v0 = load(alloca(vec_type))
				v0 = insert_element(v0, fun.params[0], RCGTK::NativeInt.new(0))
				v0 = insert_element(v0, fun.params[1], RCGTK::NativeInt.new(1))

				v1 = load(alloca(vec_type))
				v1 = insert_element(v1, fun.params[2], RCGTK::NativeInt.new(0))
				v1 = insert_element(v1, fun.params[3], RCGTK::NativeInt.new(1))

				v2 = shuffle_vector(v0, v1, RCGTK::ConstantVector.new([RCGTK::NativeInt.new(0), RCGTK::NativeInt.new(3)]))

				ret(add(extract_element(v2, RCGTK::NativeInt.new(0)), extract_element(v2, RCGTK::NativeInt.new(1))))
			end
		end

		assert_equal(5, @jit.run_function(fun, 1, 2, 3, 4).to_i)
	end

	def test_constant_struct_from_size_packed
		struct = RCGTK::ConstantStruct.new(2, true) { |i| RCGTK::NativeInt.new(i) }

		assert_instance_of(RCGTK::ConstantStruct, struct)
		assert_equal(2, struct.operands.size)
	end

	def test_constant_struct_from_size_unpacked
		struct = RCGTK::ConstantStruct.new(2, false) { |i| RCGTK::NativeInt.new(i) }

		assert_instance_of(RCGTK::ConstantStruct, struct)
		assert_equal(2, struct.operands.size)
	end

	def test_constant_struct_from_values_packed
		struct = RCGTK::ConstantStruct.new([RCGTK::NativeInt.new(0), RCGTK::NativeInt.new(1)], true)

		assert_instance_of(RCGTK::ConstantStruct, struct)
		assert_equal(2, struct.operands.size)
	end

	def test_constant_struct_from_values_unpacked
		struct = RCGTK::ConstantStruct.new([RCGTK::NativeInt.new(0), RCGTK::NativeInt.new(1)], false)

		assert_instance_of(RCGTK::ConstantStruct, struct)
		assert_equal(2, struct.operands.size)
	end

	def test_equality
		v0 = RCGTK::NativeInt.new(0)
		v1 = RCGTK::NativeInt.new(1)
		v2 = RCGTK::NativeInt.new(v0.ptr)

		assert_equal(v0, v2)
		refute_equal(v0, v1)
	end
end
