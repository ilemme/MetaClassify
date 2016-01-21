#!/usr/bin/ruby


USAGE = "Usage: #{$0} megan.txt gold.txt"

meganhash = Hash.new
m_taxid = nil
m_read = nil

if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
else

  begin
    megan = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[1]}."
    exit 1
  end
  
  begin
    gold = File.open(ARGV[1],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end
  
  megan.each_line do |line|
    line=line.chomp!
    s = line.split("\t")
    m_read = s[0]
    m_taxid = s[1]
    meganhash[m_read] = m_taxid
  end

=begin
 meganhash.each {|key, value|
                puts "#{key}\t#{value}"
               }
=end
  
  gold.each_line do |line|
    line = line.chomp!
    s = line.split("\t")
     # meganhash.each {|key, value|
    if meganhash.has_key?(s[0])
      #if key.match("#{s[0]}")
       puts "#{meganhash[s[0]]}\t#{s[1]}"
    end
        #puts "#{value}\t#{s[1]}"
        #samples.write("#{value}\t#{s[1]}")
=begin
        if value == s[1]
          puts "=\t#{key}\t#{value}\t#{s[1]}"
        else 
          puts "!=\t#{key}\t#{value}\t#{s[1]}" 
        end
=end
  end
end
  