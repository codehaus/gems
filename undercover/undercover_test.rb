require 'test/unit'
require 'undercover'

class UnderCoverTest < Test::Unit::TestCase
	def test_can_parse
		uc = UnderCover.new()
		uc.cover("isthiscovered.rb")
		uc.enable
		load "isthiscovered.rb"
		uc.write_coverage
		
		assert(!@build.is_log_file("."), ". is not a log file")
		assert(@build.is_log_file("1.log"), "1.log is a log file")
	end
end
