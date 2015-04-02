require './extractor'


ex = Extractor::RubyExtractor.new('./url_list.txt')
ex.setGemfileList
#p ex.getGemfileList
ex.setGemLicense
#p ex.getGemfileList
