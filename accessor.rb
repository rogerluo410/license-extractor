module Extractor
  module Accessor
      def readInLine(file,container)
          File.open(file,"r").each_line do | line |
               container << line.strip 
          end
      end

      def readWithCommaSeparate(file,container)
          File.open(file,"r").each_line do | line |
               container << line.split(',')
          end
      end

      def readTest(str,container)
          str = " builder, 2.1.2\n   cookiejar,0.3.2\n webmock\n"
          str.each_line do | line |
               container << line.strip.split(',')  
          end
      end
 
      def writeFile(filename,filecontent,mode = 'w')
           File.open(filename,mode) { | file | file.write(filecontent) }
      end  
  end
end
