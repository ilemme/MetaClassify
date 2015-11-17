#!/usr/bin/env ruby

dat  = ARGV[0].to_s
output= ARGV[1].to_s

@names=Array.new
@n=0

  datei = File.open(dat, "r")
  input= datei.readlines
  datei.close
    input.each do |i|
	i= i.split("\t")
	i= i[1].split("_")
	
	name="#{i[0]} #{i[1]}"
	if !@names.include? name
	  @names[@n]= name
	  @n= @n+1
	end
      end
  

fout = File.open(output, "w")
fout.puts dat
fout.write("\n")
fout.puts @names.sort
fout.close