#!/usr/bin/env ruby
#
# Mac OS X webarchive is a binary format of a plist file. You can extract the contents manually:
#  1. convert the plist file into XML by "plutil -convert xml1 file.webarchive"
#  2. parse the resulted XML file by some XML parser
#  3. decode "WebResourceData" by Base64.decode64(data) in each key
#  4. save the decoded content into a file indicated by "WebResourceData"
# Thankfully, the plist library can take care of annoying steps 2 and 3.
#
# Preparation:
#  % gem install plist
#
# Usage:
#  % unwebarchive.rb filename.webarchive
#
# Result:
#  You'll find the extracted contents under the 'filename/' directory.
#

require 'rubygems'
require 'fileutils'
require 'plist'

webarchive = ARGV.shift
exportdir = File.basename(webarchive, ".webarchive")

class UnWebarchive

  def initialize(webarchive, exportdir)
    @file = webarchive
    @dir  = exportdir

    prepare_exportdir
    parse_webarchive
  end

  def prepare_exportdir
    if File.exists?(@dir)
      print "Override existing export directory '#{@dir}' [Yes/No]? "
      exit 1 unless gets.chomp[/^y(es)?$/i]
    end
    FileUtils.mkdir_p(@dir)
    FileUtils.cp(@file, @dir)
  end

  def parse_webarchive
    FileUtils.cd(@dir) do
      system("plutil -convert xml1 #{@file}")
      plist = Plist.parse_xml(File.read(@file))
      print "#{plist}\n"
      file = plist["WebMainResource"]["WebResourceURL"]
      data = plist["WebMainResource"]["WebResourceData"].read
      data.gsub!(/file:\/\/\//, './')
      export(file, data)
      plist["WebSubresources"]||[].each do |res|
        file = res["WebResourceURL"]
        data = res["WebResourceData"].read
        export(file, data)
      end
    end
  end

  def export(resource_uri, resource_data)
    if resource_uri[/^file:/]
      name = resource_uri.sub('file:///', '')
      puts "Writing '#{@dir}/#{name}' ..."
      File.open(name, "w") do |file|
        file.print resource_data
      end
    end
  end
end

UnWebarchive.new(webarchive, exportdir)