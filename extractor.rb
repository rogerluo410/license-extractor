require 'spidr'
require './task'

module Extractor
  class Extractor
        
  end

  class RubyExtractor < Extractor
        def initialize file
            raise "File is not exist" unless File.exist?(file)
            @file        = file
            @task        = Task.new
            @gemfileList = []
        end

        def setGemfileList
            @task.importQueue(@file,:readInLine)
            p = Proc.new do | url |
                Spidr.site(url) do |spider|
                  spider.every_page do | page |
                    @gemfileList = page
                  end
                end
            end #end Proc
            @task.execution(p)
       end
  
       def getGemfileList
           @gemfileList  
       end
    
       
  end
end
