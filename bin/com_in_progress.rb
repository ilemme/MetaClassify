#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require_relative 'fastaparser2.rb'


def parseargs(argv, path)
  options = OpenStruct.new
  
  options.path = Array.new
  opts = OptionParser.new do |opts|
  opts.on("-o DIR","--o_path","path to Output") do |dir|
    path.push(dir)
  end
  opts.on("-d DIR","--db_path","path to Database") do |dir|
    path.push(dir)
    puts path
  end
  opts.on("-s DIR","--ds_path DIR","path to Dataset") do |dir|
    options.path = dir
    puts options.path
  end
  opts.on("-h","--help","Show this message") do |h|
    puts optionparser
    exit
  end
  end
  return options
end

path = Array.new  
options = parseargs(ARGV, path)

options.path.each do |x|
  if x.match(/data_sets/)
    extend Fasta_parser
    hash = Hash.new
    hash = self.mainly(hash, x.to_s)
    hash.each {|k,v|
             puts "#{k}\t#{v}" }
  end
end
