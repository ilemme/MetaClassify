#!/usr/bin/env ruby

path  = ARGV[0].to_s
output= ARGV[1].to_s

@names=Array.new
@n=0

Dir.foreach(path) do |fas|
  next if fas=='.' or fas=='..'
  datei = File.open(path+"//"+fas, "r")
  input= datei.readlines
  datei.close
    input.each do |i|
      if i.match (/^(>|\s*$|\s*#)/)
	i= i.split("SOURCE_1=")
	i= i[1].split()
	
	name="#{i[0]} #{i[1]}"
	name=name.gsub(/["]/,"")
	if !@names.include? name
	  @names[@n]= name
	  @n= @n+1
	end
      end
    end
  end

fout = File.open(output, "w")
fout.puts path
fout.write("\n")
fout.puts @names.sort
fout.close