require './extractor'


begin
  p ARGV[0]
  raise Error.new("File(#{file}) is not exist.") unless File.exist?(ARGV[0])
  file = ARGV[0]
  File.open(file,"r").each_line do | line |
    if !line.eql? nil or !line.strip.empty?
        repo_info = line.strip
        repo_attr = repo_info.split(',')[0]
        repo_url  = repo_info.split(',')[1]
        p repo_url
        case repo_attr.upcase
          when 'RUBY' then
            ex = Extractor::RubyExtractor.new(repo_url,20)
            ex.setGemfile
            ex.setGemLicense
            ex.writeFile
          when 'GO' then

          when 'JAVA' then

        end
    end
  end
rescue StandardError => e
   p "Error:    #{e.message}"
   p "BackTrace:#{e.backtrace}"   
end
