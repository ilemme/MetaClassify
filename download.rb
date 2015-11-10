#!/usr/bin/env/ ruby

require 'net/http'
require 'net/ftp'
require 'uri'
require 'date'




	sources_file = ARGV[0]
	filename = ARGV[1]
	
    
    path= filename.to_s
    source_file=sources_file.to_s
    
    system("wget -P #{path} #{source_file}")

	
	
	f = File.open("download_protocol.txt", "a")
	f.write "> #{Time.now}\n Download from '#{sources_file}' as '#{filename}'\n\n"


if __FILE__ == $0
	usage = <<-EOU
	usage: ruby #{File.basename($0)} URL Destination
	EOU
	
	abort usage if ARGV.length != 2
	
end
