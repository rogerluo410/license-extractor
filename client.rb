require './extractor'


ex = Extractor::RubyExtractor.new('./url_list.txt')
ex.setGemfileList
ex.setGemLicense
#p ex.getGemfileList
