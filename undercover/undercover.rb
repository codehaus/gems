# :nodoc:
#
# Author:: Aslak Hellesoy and Jon Tirsen.
# Copyright:: Copyright (c) 2003-2010 Aslak Hellesoy and Jon Tirsen. All rights reserved.
# License:: Ruby license.

class UnderCover
	def initialize()
		@files = []
		@hits = []
		@loc = Hash.new(0)
		@covered_loc = Hash.new(0)
	end
	
	def cover(file)
		@files<<File.expand_path(file)
	end

	def enable
		set_trace_func proc { |event, file, line_number, id, binding, classname|
			disable
			covered(event, file, line_number, id, binding, classname)
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
				line_number = 1
				io.each_line do |line|
					output(file, line_number, line)
					line_number = line_number + 1
				end
			end
			stats(file)
		end
	end
	
	def output(file, line_number, line)
		hit = Hit.new(nil, file, line_number, nil, nil, nil)
		if(unexecutable?(line))
			puts line
		else
			if(@hits.index(hit))
				puts line
				@covered_loc[file] = @covered_loc[file] + 1
			else
				puts "#{line.chomp}    # NOT COVERED"
			end
			@loc[file] = @loc[file] + 1
		end
	end
	
	def unexecutable?(line)
		line =~ /.*end.*/ || line =~ /^\s*$/
	end
	
	def stats(file)
		puts "+++ #{file} +++"
		puts "LOC:#{@loc[file]}"
		percentage = @covered_loc[file] / @loc[file]
		puts "Covered:#{@covered_loc[file]} (#{percentage})"
	end
end

class Hit
	attr_reader :event, :file, :line_number, :id, :binding, :classname
	
	def initialize(event, file, line_number, id, binding, classname)
		@event = event
		@file = file
		@line_number = line_number
		@id = id
		@binding = binding
		@classname = classname
	end
	
	def ==(o)
		@file == o.file && @line_number == o.line_number
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
