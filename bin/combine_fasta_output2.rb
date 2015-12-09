#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require_relative 'fastaparser2.rb'


def parseargs(argv, path)
  options = OpenStruct.new
  optionparser = OptionParser.new()
  optionparser.on("-o DIR","--o_path","path to Output") do |dir|
    path.push(dir)
  end
  optionparser.on("-d DIR","--db_path","path to Database") do |dir|
    path.push(dir)
    puts path
  end
  optionparser.on("-s DIR","--ds_path","path to Dataset") do |dir|
    path = dir
    puts path
  end
  optionparser.on("-h","--help","Show this message") do 
    puts optionparser
    exit
  end
  return options
end

arr_path = Array.new  
path = parseargs(ARGV, arr_path)
=begin
path.each do |x|
  if x.match(/data_sets/)
    extend Fasta_parser
    hash = Hash.new
    hash = self.mainly(hash, x.to_s)
    hash.each {|k,v|
             puts "#{k}\t#{v}" }
  end

end
=end