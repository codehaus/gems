class Hit
	attr_reader :event, :file, :line, :id, :binding, :classname
	
	def initialize(event, file, line, id, binding, classname)
		@event = event
		@file = file
		@line = line
		@id = id
		@binding = binding
		@classname = classname
	end
	
	def ==(o)
		@file == o.file && @line == o.line
	end
end

class UnderCover
	def initialize()
		@files= []
		@hits = []
	end
	
	def cover(file)
		@files<<File.expand_path(file)
	end

	def enable
		set_trace_func proc { |event, file, line, id, binding, classname|
			disable
			covered(event, file, line, id, binding, classname)
			enable
		}
	end
	
	def disable
		set_trace_func nil
	end

	def covered(event, file, line, id, binding, classname)
		path = File.expand_path(file)
		if(@files.index(path) && execution?(binding))
			hit = Hit.new(event, path, line, id, binding, classname)
			@hits<<hit
		end
	end
	
	def execution?(binding)
		true
	end
	
	def write_coverage
		@files.each do |file|
			File.open(file) do |io|
				i = 1
				io.each_line do |line|
					output(file, line, i)
					i = i + 1
				end
			end
		end
	end
	
	def output(file, line, i)
		hit = Hit.new(nil, file, i, nil, nil, nil)
		if(@hits.index(hit))
			puts "#{line}"
		else
			if(leave_it(line))
				puts line
			else
				puts "#{line.chomp}    # NOT COVERED"
			end
		end
	end
	
	def leave_it(line)
		line =~ /.*end.*/ # JON!!! || line =~ /\s*/
	end
end

if $0 == __FILE__
	uc = UnderCover.new()
	ARGV.each do |file_spec| 
		Dir[file_spec].each do |file|
			uc.cover(file)
		end
	end
	uc.enable
	load ARGV[0]
	uc.disable
	uc.write_coverage
end
