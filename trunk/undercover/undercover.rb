
class Hit
	attr_reader :file, :line

	def initialize(file, line)
		@file = file
		@line = line
	end
	
	def to_s
		"#{file}:#{line}"
	end
	
	def in_file(file)
		@file == file
	end
	
	def ==(o)
		@file == o.file && @line == o.line
	end
end

class UnderCover
	def initialize
		@files= []
		@hits = []
		@covered_lines = 0
	end
	
	def start
		set_trace_func proc { |event, file, line, id, binding, classname|
			stop
			covered(file, line)
			start
		}
	end
	
	def stop
		set_trace_func nil
	end
	
	def covered(file, line)
		hit = Hit.new(file, line)
		@hits<<hit if count_as_hit(hit)
	end
	
	def count_as_hit(hit)
		in_files = @files.find do |file|
			hit.in_file(file)
		end
		puts in_files
		already_counted = @hits.index(hit)
		puts already_counted
		in_files && !already_counted
	end
	
	def covered_lines
		@hits.size
	end

	def add_file(file)
		@files<<file
	end
	
	def print_report
		total_lines=0
		@files.each do |file|
			total_lines += lines_in_file(file)
		end
		@hits.each do |hit|
			puts hit
		end
		puts "total lines: #{total_lines}"
		puts "covered lines: #{covered_lines}"
	end
	
	def lines_in_file(file)
		total_lines = 0
		File.open(file) do |io|
			io.each_line do |line|
				total_lines += 1
			end
		end
		total_lines
	end
end

uc = UnderCover.new

uc.add_file(ARGV[0])

uc.start

# load and exec run in test source
load ARGV[0]
uc.stop

uc.print_report
