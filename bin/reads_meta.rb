#!/usr/bin/env ruby

USAGE = "ruby #{$0} dataset_path output"

if ARGV.length != 2
  puts USAGE
else
path  = ARGV[0].to_s
output= ARGV[1].to_s

@code=Hash.new

Dir.foreach(path) do |fas|
  next if fas=='.' or fas=='..'
  datei = File.open(path+"/"+fas, "rb:UTF-8")
  input= datei.readlines
  datei.close
    input.each do |i|
      if i.match ("genus")
	k= i.split()
	
	name="#{k[2]}"
	code = "#{k[0]}"

	name=name.gsub(/["]/,"")
	if !@code.include? code
	  @code[code]=name
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
