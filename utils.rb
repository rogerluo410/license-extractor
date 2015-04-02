require 'anemone'
module Utils

  def getHtmlWithAnemone(url)
      Anemone.crawl(url,:discard_page_bodies => true,:depth_limit => 0) do |anemone|
        anemone.on_every_page do |page|
         return nil  if page.not_found?
         return yield(page) if block_given?
        end
      end
  end
 
end
