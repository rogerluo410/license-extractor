require 'anemone'
require './task'
require './utils'
require './accessor'
require './exceptions'

module Extractor
  class Extractor
        include Utils,Accessor
  end

  class RubyExtractor < Extractor
        def initialize file
            raise Error.new("File(#{file}) is not exist.") unless File.exist?(file)
            @file              = file
            @getGemFileTask    = Task.new
            @getGemLicenseTask = Task.new
            @gemfileList       = []
        end

        def setGemfileList
            @getGemFileTask.importQueue(@file,:readInLine)
            p = Proc.new do | url |
                    gemfile      = getHtmlWithAnemone(url) { |page| page.body }
                    raise Error.new("Page #{url} that you're visiting is not found.") if gemfile.eql? nil
                    @gemfileList << {"name" => url  , "gemfile" => gemfile}
            end #end Proc
            @getGemFileTask.execution(p)
       end
  
       def getGemfileList
           @gemfileList  
       end
    
       def getGemfileList?
           @gemfileList.empty?
       end

       def setGemLicense
           licenseList = []
           p = Proc.new do |  ruby_pair |
              p ruby_pair
              ruby_name        = ruby_pair.strip.split(',')[0]
              version          = ruby_pair.strip.split(',')[1]
              #"1.0" => "1.0.0" 
              if !version.eql? nil and version.count('.')  == 1
                 version += '.0' 
              end  
              url = "https://rubygems.org/gems/"
              url += "#{ruby_name}" unless ruby_name.empty?
              url += "/versions/#{version}" unless version.eql? nil
              pair = getHtmlWithAnemone(url) do |page|
                  license = page.doc.css("span.gem__ruby-version").css('p').inner_text
                  version = page.doc.css("i.page__subheading").inner_text
                  [version,license]
             end
             unless pair.eql? nil 
                licenseList << "#{ruby_name},#{pair[0]},#{pair[1]}\n"
             else
                licenseList << "#{ruby_name},#{version},Not Found\n"
             end
           end #end Proc

           raise Error.new("Failed to get Gemfile from Github.") if getGemfileList?  

           @gemfileList.each do | gem |
             failureList = @getGemLicenseTask.importQueue(gem["gemfile"],:extract_ruby)
             p "fail: #{failureList}"
             @getGemLicenseTask.execution(p)
             #Write into file
             filename = "#{gem["name"].split('/')[4]}.txt"
             p "show1:#{licenseList}"
             unless failureList.eql? nil and failureList.empty? 
                  licenseList << "---------Failed to extract name and version-----------\n"
                  licenseList.concat(failureList)
             end
             writeRubyFile(filename,licenseList)
             licenseList.clear unless licenseList.empty? 
           end 
       end

   end # end RubyExtractor
end
