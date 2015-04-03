require './extractor'

begin
ex = Extractor::RubyExtractor.new('./url_list.txt')
ex.setGemfileList
ex.setGemLicense
rescue StandardError => e
   p "Error:#{e.message}"
   p e.backtrace   
end
