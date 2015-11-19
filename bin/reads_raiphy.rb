#!/usr/bin/env ruby

USAGE = "ruby #{$0} dataset_path output"

if ARGV.length != 2
  puts USAGE
else
path  = ARGV[0].to_s
output= ARGV[1].to_s

#@names=Hash.new
@code=Hash.new

Dir.foreach(path) do |fas|
  next if fas=='.' or fas=='..'
  datei = File.open(path+"//"+fas, "rb:UTF-8")
  input= datei.readlines
  datei.close
    input.each do |i|
      if i.match (/^(>|\s*$|\s*#)/)
	k= i.split()
	j= i.split("|")
	#j= j[1].split("|")
	
	name="#{k[1]} #{k[2]}"
	code = "#{j[1]}"

	if !@code.include? code
	#  @names[@n]= name
	  @code[code]=name
	  #@n= @n+1
	end
      end
    end
  end

fout = File.open(output, "w")
fout.puts path
fout.write("\n")
@code.each {|key, value|
  fout.puts "#{key}\t#{value}"
           }
fout.close
end
