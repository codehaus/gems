class IsThisCovered
	def also_run()
		a = 10
	end

	def run()
		a = 10
		also_run
		if(false)
			c = 22
		end
		a = 10
	end

	def not_run()
		b = 8
		b = 9
		b = 11
	end
end

itc = IsThisCovered.new()
itc.run
