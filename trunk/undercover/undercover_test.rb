require 'test/unit'
require 'undercover'

class UnderCoverTest < Test::Unit::TestCase
	def test_can_parse
		uc = UnderCover.new()
		uc.cover("isthiscovered.rb")
		uc.enable
		load "isthiscovered.rb"
		uc.write_coverage
	end
end
