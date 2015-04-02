module Extractor
  module Accessor
      def readInLine(file,container)
          File.open(file,"r").each_line do | line |
               container << line.strip unless line.eql? nil or line.strip.empty?
          end
      end

      def readWithCommaSeparate(file,container)
          File.open(file,"r").each_line do | line |
               container << line.split(',')  unless line.eql? nil or line.strip.empty?
          end
      end

      def readTest(str,container)
          str = " builder, 2.1.2\n   cookiejar,0.3.2\n webmock\n"
          str.each_line do | line |
               container << line.strip.split(',')  
          end
      end
 
      def writeRubyFile(filename,filecontent,mode = 'w')
           File.open(filename,mode) do | file |
               filecontent.each do | content | 
                     file.write(content) 
               end
           end
      end  
  end
end
