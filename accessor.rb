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
  end
end
