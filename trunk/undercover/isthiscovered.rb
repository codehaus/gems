def also_run()
	a = 10
end

def run()
	a = 10
	also_run
	a = 10
end

def not_run()
	b = 8
end

run
