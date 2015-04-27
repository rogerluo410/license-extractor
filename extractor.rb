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

        def getLicenseFromGithub(url)
            licenseUrlList ||= []
            licenseName      = ""
            licenseUrl       = ""

            getHtmlWithAnemone(url) do |page|
              page.doc.css('a[rel=nofollow]').each do | text |
                  hrefValue = text.css("/@href").map(&:value)[0]
                  licenseUrlList << hrefValue if text.inner_text == 'Homepage'    and hrefValue =~ /github.com/
                  licenseUrlList << hrefValue if text.inner_text == 'Source Code' and hrefValue =~ /github.com/
              end
            end
            return nil if licenseUrlList.empty?

            getHtmlWithAnemone(licenseUrlList[0]) do |page|
              if page.html?
                page.doc.xpath("//a[@title]").each do | title |
                  if  title.css('/@title').map(&:value).to_s =~ /(copying|license){1}(.[a-zA-Z]{0,})?[^\w\s&quot;-]+/i  and
                      title.css('/@title').map(&:value)[0].to_s[0] =~/c|l/i
                      licenseName   =  title.css('/@title').map(&:value)[0]
                      licenseName ||= ""
                  end

                  licenseUrl   = page.doc.css("a[title='#{licenseName}']").css('/@href').map(&:value)[0] unless licenseName.empty?
                  licenseUrl ||= ""
                end
              end

            end

            if !licenseUrl.empty?
               licenseUrl = "https://github.com" + licenseUrl
               license    = nil
               #return licenseUrl
               #p licenseUrl
               getHtmlWithAnemone(licenseUrl) do |page|
                       if page.html?
                          rawLicenseUrl = page.doc.css('a#raw-url').css('/@href').map(&:value)[0]
                          rawLicenseUrl ||= ""
                          if !rawLicenseUrl.empty?
                            rawLicenseUrl = "https://github.com" + rawLicenseUrl
                            #p rawLicenseUrl
                            licenseRaw    = getHtmlWithAnemone(rawLicenseUrl) { |page|  page.doc.css('a').css('/@href').map(&:value)[0] if page.html? }
                            #"<html><body>You are being <a href=\"https://raw.githubusercontent.com/sporkmonger/addressable/master/LICENSE.txt\">redirected</a>.</body></html>"
                            licenseRaw ||= ""
                            licenseText   = getHtmlWithAnemone(licenseRaw) { |page| page.body } unless licenseRaw.empty?
                            licenseText ||= ""
                            license       = ex_word(licenseText.gsub(/\\n/,' ').gsub(/\\t/,' ')) unless licenseText.empty?
                            #p "License : #{license}"
                            if license =="ERROR"
                              license = nil
                            end
                          end
                       end
               end
               return licenseUrl,license || ""
            end
            return licenseUrlList[0],""
        end

        def setGemLicense
           raise Error.new("Failed to get Gemfile from Github.") if getGemfileList?     

           licenseList = []
           p = Proc.new do |  ruby_pair |
              ruby_name        = ruby_pair.strip.split(',')[0]
              version          = ruby_pair.strip.split(',')[1]
              #"1.0" => "1.0.0"  Completing
              if !version.eql? nil and version.count('.')  == 1
                 version += '.0' 
              end  
              url = "https://rubygems.org/gems/"
              url += "#{ruby_name}"         unless ruby_name.empty?
              url += "/versions/#{version}" unless version.eql? nil
              pair = getHtmlWithAnemone(url) do |page|
                  license = page.doc.css("span.gem__ruby-version").css('p').inner_text
                  version = page.doc.css("i.page__subheading").inner_text
                  [version,license]
              end


             unless pair.eql? nil
                if pair[1] == 'N/A'
                  licenseInfo = ""
                  licenseUrl  = getLicenseFromGithub(url)
                   if licenseUrl.eql? nil
                       licenseInfo = "Not Found Github Url"
                   elsif !licenseUrl.empty?
                       licenseInfo = licenseUrl[0]
                       pair[1]     = licenseUrl[1] unless licenseUrl[1].empty?
                   end
                   licenseList << "#{ruby_name},#{pair[0]},#{pair[1]},#{url},#{licenseInfo}\n"
                else
                   licenseList << "#{ruby_name},#{pair[0]},#{pair[1]},#{url}\n"
                end
             else
                #licenseList << "#{ruby_name},#{version},#{url},Not Found The Page\n"
                #Adjust searching depth of the URL
               #@getGemLicenseTask.instance_eval do
                   #p "enter instance_eval #{ruby_name}..."
                   #@queue << "#{ruby_name}," #without version
                   p.call("#{ruby_name},")
               #end
             end #end unless
           end #end Proc

           @gemfileList.each do | gem |
             failureList = @getGemLicenseTask.importQueue(gem["gemfile"],:extract_ruby)
             @getGemLicenseTask.execution(p)
             #Write into file
             filename = "#{gem["name"].split('/')[4]}.txt"
             if !failureList.eql? nil and !failureList.empty? 
                  licenseList << "---------Failed to extract name and version-----------\n"
                  licenseList.concat(failureList)
             end
             writeRubyFile(filename,licenseList)
             licenseList.clear unless licenseList.empty? 
           end 
        end
   end # end RubyExtractor
end
