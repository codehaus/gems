require 'test/unit'
require 'isthiscovered'

class UnderCoverTest < Test::Unit::TestCase
	def test_can_parse
		itc = IsThisCovered.new()
		itc.run
	end
end
