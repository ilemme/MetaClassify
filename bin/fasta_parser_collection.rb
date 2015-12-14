#!/usr/bin/ruby

module Fasta_parser_collection

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