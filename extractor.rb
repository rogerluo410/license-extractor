require 'anemone'
require './task'
require './utils'
require './accessor'

module Extractor
  class Extractor
        include Utils,Accessor
  end

  class RubyExtractor < Extractor
        def initialize file
            raise "File(#{file}) is not exist" unless File.exist?(file)
            @file              = file
            @getGemFileTask    = Task.new
            @getGemLicenseTask = Task.new
            @gemfileList       = []
        end

        def setGemfileList
            @getGemFileTask.importQueue(@file,:readInLine)
            p = Proc.new do | url |
                    gemfile      = getHtmlWithAnemone(url) { |page| page.body }
                    @gemfileList << {"name" => url  , "gemfile" => gemfile}
            end #end Proc
            @getGemFileTask.execution(p)
       end
  
       def getGemfileList
           @gemfileList  
       end
    
       def getGemfileList?
           !@gemfileList.empty?
       end

       def setGemLicense
           licenseList = []
           p = Proc.new do |  ruby_pair |
              ruby_name        = ruby_pair[0].strip
              version          = ruby_pair[1].strip  unless ruby_pair[1].eql? nil
              p version
              url = "https://rubygems.org/gems/"
              url += "#{ruby_name}" unless ruby_name.empty?
              url += "/versions/#{version}" unless version.eql? nil
              p url
              pair = getHtmlWithAnemone(url) do |page|
                  license = page.doc.css("span.gem__ruby-version").css('p').inner_text
                  version = page.doc.css("i.page__subheading").inner_text
                  [version,license]
             end
             licenseList << "#{ruby_name},#{pair[0]},#{pair[1]}\n"
           end #end Proc
           #p @gemfileList
           @gemfileList.each do | gem |
             @getGemLicenseTask.importQueue(gem[:gemfile],:readTest)
             @getGemLicenseTask.execution(p)
             #Write into file
             p licenseList
             writeFile(gem[:name],licenseList)
             licenseList.clear unless licenseList.empty? 
           end 
       end

   end # end RubyExtractor
end
