require './extractor'


ex = Extractor::RubyExtractor.new('./roger/url_list.txt')
ex.setGemfileList
p ex.getGemfileList
