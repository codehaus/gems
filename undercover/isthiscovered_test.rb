require 'test/unit'
require 'isthiscovered'

# I want this to magically just blend in :-)
require 'undercover'

class IsThisCoveredTest < Test::Unit::TestCase
	def test_it
		itoc = IsThisCovered.new
		itoc.run
	end
end
