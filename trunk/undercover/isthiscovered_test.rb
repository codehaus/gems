require 'test/unit'
require 'isthiscovered'

class IsThisCoveredTest < Test::Unit::TestCase
	def test_it
		itoc = IsThisCovered.new
		itoc.run
	end
end
