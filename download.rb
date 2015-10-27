#!/usr/bin/env/ ruby

require 'net/http'
require 'net/ftp'
require 'uri'
require 'date'

def create_directory(dirname)
	unless Dir.exists?(dirname)
		Dir.mkdir(dirname)
	else
		puts "Skipping creating directory " + dirname + ". It already exists."
	end
end

def download_resource(resource, filename)
	uri = URI.parse(resource)
	case uri.scheme.downcase
	when /http|https/
		http_download_uri(uri, filename)
	when /ftp/
		ftp_download_uri(uri, filename)
	else
		puts "Unsupported URI scheme for resource " + resource + "."
	end
end

def http_download_uri(uri, filename)
	puts "Starting HTTP download for: " + uri.to_s
	http_object = Net::HTTP.new(uri.host, uri.port)
	http_object.use_ssl = true if uri.scheme == 'https'
	begin
		http_object.start do |http|
			request = Net::HTTP::Get.new uri.request_uri
			http.read_timeout = 500
			http.request request do |response|
				open filename, 'w' do |io|
					response.read_body do |chunk|
						io.write chunk
					end
				end
			end
		end
	rescue Exception => e
		puts "=> Exception: '#{e}'. Skipping download."
		return
	end
	puts "Stored download as " + filename + "."
end

def ftp_download_uri(uri, filename)
	puts "Starting FTP download for: " + uri.to_s + "."
	dirname = File.dirname(uri.path)
	basename = File.basename(uri.path)
	begin
		Net::FTP.open(uri.host) do |ftp|
			ftp.login
			ftp.chdir(dirname)
			ftp.getbinaryfile(basename)
		end
	rescue Exception => e
		puts "=> Exception: '#{e}'. Skipping download."
		return
	end
	puts "Stored download as " + filename + "."
end

def download_resources(pairs)
	pairs.each do |pair|
		filename = pair[:filename].to_s
		resource = pair[:resource].to_s
		unless File.exists?(filename)
			download_resource(resource, filename)
		else
			puts "Skipping download for " + filename + ". It already exists."
		end
	end
end


def main
	sources_file = ARGV[0]
	filename = ARGV[1]

	uris = Array.new
	pair=Array.new

	parts = [sources_file, filename]
	pair = Hash[ [:resource, :filename].zip(parts) ]
	uris.push(pair)

	target_dir_name = Date.today.strftime('%d-%m-%y')
	puts target_dir_name

	create_directory(target_dir_name)
	Dir.chdir(target_dir_name)
	path = Dir.pwd
	f = File.open("download_protocol.txt", "a")
	f.write "> #{Time.now}\n  Working on directory: '#{path}'\n  Download from '#{sources_file}' as '#{filename}'\n\n"

	download_resources(uris)
end

if __FILE__ == $0
	usage = <<-EOU
	usage: ruby #{File.basename($0)} http:://www.domain.com/file target_file_name
	EOU
	
	abort usage if ARGV.length != 2
	
main
end
