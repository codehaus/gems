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

	# This can't be covered anyway

	def not_run()
		@a =	1
		@bee = 	2
		b = 8
		b = 9
		b = 11
	end
end
