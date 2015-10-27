#!/usr/bin/env/ ruby

#how to move a file

require 'fileutils'


begin
  FileUtils.mv(ARGV[0], ARGV[1])
  f = File.open("protocol.txt", 'a')
  f.write "#{Time.now} > file '#{ARGV[0]}' moved to '#{ARGV[1]}'\n"
rescue
  raise "usage: ruby #{$0} filename destination"
end
