# :nodoc:
#
# Author:: Aslak Hellesoy and Jon Tirsen.
# Copyright:: Copyright (c) 2003-2010 Aslak Hellesoy and Jon Tirsen. All rights reserved.
# License:: Ruby license.

    class TestCase
      def TestCase.inherited(subclass) # intercept test cases
        puts "YAHOOO: #{subclass.to_s}"
      end
    end

    class UnderCover
      def initialize()
        @files = []
        @hits = []
        @loc = Hash.new(0)
        @covered_loc = Hash.new(0)
      end

      def cover(file)
        file = File.expand_path(file)
        @files<<file unless @files.index(file)
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
            puts undercover(line)
          end
          @loc[file] = @loc[file] + 1
        end
      end
      
      def undercover(line)
        chomped = line.chomp
	spaces = 70 - chomped.size
	"#{chomped} #{spaces} # NOT COVERED"
      end

      def unexecutable?(line)
        line =~ /.*end.*/ || line =~ /^\s*$/
      end

      def stats(file)
        puts "+++ #{file} +++"
        puts "LOC:#{@loc[file]}"
        percentage = @covered_loc[file].to_f / @loc[file].to_f * 100
        puts "Covered:#{@covered_loc[file]} (#{percentage}%)"
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

# Load all the files to cover
if($0 == __FILE__)
	uc = UnderCover.new()
	ARGV.each { |fileset|
		Dir[fileset].each {|file|
			uc.cover(file)
		}
	}
	main_script = ARGV[0]
	ARGV.clear

	uc.enable
	at_exit {
		uc.disable
		uc.write_coverage
	}
	load main_script
end
