# Author:      Chris Wailes <chris.wailes@gmail.com>
# Project:     Ruby Code Generation Toolkit
# Date:        2012/05/04
# Description: This file contains unit tests for rcgtk/llvm.rb file.

############
# Requires #
############

# Gems
require 'minitest/autorun'

# Ruby Language Toolkit
require 'rcgtk/version'
require 'rcgtk/llvm'

#######################
# Classes and Modules #
#######################

class LLVMTester < Minitest::Test
	def test_init
		assert_raises(ArgumentError) { RCGTK::LLVM.init(:foo) }
	end
end
