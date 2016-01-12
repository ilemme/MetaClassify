#!/usr/bin/ruby

module Fasta_parser_collection


def self.enum_files_in_subtree(directory)
  stack = Array.new()
  stack.push(directory)
  while not stack.empty?
    subdir = stack.pop
      Dir.entries(subdir).each do |entry|
	if not entry.match(/^\.\.?$/)
	  if File.stat(subdir + "/" + entry).file?
	    yield subdir + "/" + entry
	  else
	    stack.push(subdir + "/" + entry)
	  end
	end
      end
    end
  end
end

# given the name of an inputfile in fasta format, open it and extract
# the header line from it
def self.extract_fasta_header(inputfile)
  begin
    f = File.new(inputfile,"r")
  rescue => err
    STDERR.puts "#{$0}: cannot open inputfile #{inputfile}: #{err}"
    exit 1
  end
  f.each_line do |line|
    if line.match(/^>/)
      yield line.chomp
    end
  end
end

