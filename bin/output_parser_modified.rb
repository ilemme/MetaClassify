#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require 'set'

def parseargs(outputs, argv)
  options = OpenStruct.new
  options.output_ids = nil
  options.datasetpath = "/scratch/gi/studprj/metaclassify"
  optionparser = OptionParser.new()
  # rename following option to switch on mode which outputs extra values
  optionparser.on("-l","--lambda-only","parse only lambda output") do |x|
    outputs = ["lambdatest"]
  end
  optionparser.on("-d","--diamond-only","parse only diamond output") do |x|
    outputs = ["diamond_output"]
  end
  optionparser.on("-h","--help","Show this message") do
    puts optionparser
    exit
  end

  rest = optionparser.parse(argv)
  if !rest.empty?
    STDERR.puts "Wrong input."
    STDERR.puts optionparser
    exit 1
  else
    options.output_ids = outputs
    options.output_ids.each do |name|
      if not outputs.member?(name)
        STDERR.puts "#{$0}: illegal name #{name}: possible names of outputs " +
                    "are " + outputs.join(", ")
        exit 1
      end
    end
  end
  return options
end

def enum_files_in_subtree(directory)
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

# use the previous function to enumerate all files in directory and
# select only those that are fasta files based on the the possible suffixes
# of the file names

def enum_m8_files_in_subtree(directory)
  enum_files_in_subtree(directory) do |filename|
    if filename.match(/\.m8$/) # extend possible suffixes
      yield filename
    end
  end
end

# given the name of an inputfile in m8 format, open it and extract
# the header line from it

def extract_header(inputfile)
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

#following function
#includes name and id given by the different functions into the hash matching_map

#output-parser lambda

def output_parser(line, matching_map)
  s = line.split("\t") 
  query_id = s[0]
  if query_id.nil?
    STDERR.puts "No id found"
    exit 1
  end
  database_id = s[1]
  if database_id.nil?
   STDERR.puts "No name found"
   exit 1
  end 
  matching_map[query_id.to_sym].add(database_id.to_sym)
end

outputs = ["Lambda", "Diamond"]
options = parseargs(outputs, ARGV)

matching_map = Hash.new{|h,k| h[k] = Set.new}

  
options.output_ids.each do |output_id|
  enum_m8_files_in_subtree(options.datasetpath + "/" +
                              output_id) do |filename|
    extract_header(filename) do |header|
      output_parser(header, matching_map)       
    end
#     puts filename
#     newfile = File.new(filename+".txt", "w")
#     newfile.write("aehm hallo")
#     matching_map.each {|key,value|              
#                        puts "#{key}\t#{value.size}"}
#     matching_map.clear
  end
end


matching_map.each {|key,value|              
    puts "#{key}\t#{value.size}"}
                 
