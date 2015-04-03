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
    
      #For test
      def readTest(str,container)
          str = " builder, 2.1.2\n   cookiejar,0.3.2\n webmock\n"
          str.each_line do | line |
               container << line.strip.split(',')  
          end
      end
 
      def writeRubyFile(filename,filecontent,mode = 'w')
           File.open(filename,mode) do | file |
               filecontent.each do | content |
                     p content 
                     file.write(content) 
               end
           end
      end 

      
      def rule(string)
          exact_name = ''
          exact_version = '' 
          index_version_begin = 0
          index_version_end   = 0
          flag = "open"

          #stack 1
          stack1 = Array.new();
    
          #stack 2
          stack2 = Array.new();
    
          result = string =~ /[ ][(]/;# no return nil
    
    
          if (string.size() == 0 ) then
             exact_name = "ERROR";
          #only package name        
          elsif (result == nil)
                for i in (0 ... string.size())  do
                   if (string[i] =~ /[0-9a-zA-Z_-]/)
                      stack1.push(string[i]);
                   else
                      exact_name = "ERROR";
                      break;
                   end
                end
          # name and version
          else       
               for i in (0 ... string.size()) do
                  if (string[i] == ' ' and string[i+1] == '(')
                     break;
                  end    
               end
               #name    
               for j in (0 ... i)  do #string[i] == ' '
                   if (string[j] =~ /[0-9a-zA-Z_-]/)
                      stack1.push(string[j]);
                   else
                      exact_name = "ERROR";                
                      break;
                   end
               end        
        
               if (string =~ /[^!][=]/ )
                  for j in (i ...string.size()) do
                      if (string[j-1] != '!' and string[j] == '=' and string[j+1] == ' ')
                         index_version_begin = j+2;
                         index_version_end = j+2;
                         for k in (j+2 ... string.size()) do
                            if (string[k] == ',' or string[k] == ')')
                               index_version_end = k;
                               break;
                            end    
                         end
                         break;
                      elsif ((string[j] =~ /[0-9a-zA-Z.><~!=(, ]/)  == nil )
                            exact_name = "ERROR";
                            break;
                      end
                  end
               else
                  for j in (i ... string.size()) do
                     if (string[j] == '=')
                        flag = "close";
                     elsif (string[j] == ',')
                        flag = "open";
                     end
                     if (flag == "open" and (string[j] == ' ' or string[j] == '(') and string[j+1] =~ /[0-9a-zA-Z.]/ )
                        index_version_begin = j+1;
                        index_version_end = j+1;
                        for k in (j+1 ... string.size()) do
                           if (string[k] == ',' or string[k] == ')')
                               index_version_end = k;
                               break;
                           end
                        end
                        break;
                     elsif ((string[j] =~ /[0-9a-zA-Z.><~!=(, ]/)  == nil )
                            exact_name = "ERROR";
                            break;
                     end
                  end
               end
               #version        
               for k in (index_version_begin ... index_version_end) do
                  if (string[k] =~ /[0-9a-zA-Z.]/)
                     stack2.push(string[k]);
                  else
                     exact_name = "ERROR";
                     break;
                  end
               end
             end    
   
             # return package name and package version    
             if (exact_name == "ERROR")
                return exact_name
             else
                return stack1.join() + "," + stack2.join();
             end
         end # end rule

         #input:输入的字符串
         #rs:分隔符
         #start_1,start_2,start_3:开始记录name、version 标志
         #finish_1，finish_2，finish_3:结束记录name、version 标志
         # return: 如果返回字符串"ERROR"表示数据不对，无法处理
         #         返回数组，数组第一个元素是改好豆进格式的name、version
         #         第二个元素是无法用程序改的name,version
         def extract_ruby(input,container,rs = $/,start_1 = "GEM",start_2 = "remote: http://rubygems.org/",start_3 = "specs:",finish_1 = "",finish_2 = "PLATFORMS",finish_3 = "ruby")
             if (input.size() == 0) then
                #puts "string is nil!"
                return nil
             end
    
             index_start = 0;
             index_end   = 0;
             line = '';
             line1 = ''
             line2 = ''
             flag = "close";
    
             lines = Array.new();
             out_lines = Array.new();#return valid
             succeed = Array.new();
             failure = Array.new();
             input.each_line(rs) do |line|
                    lines.push(line);
             end
    
             for i in (0...lines.size()-2) do
                if (lines[i] == "\n" or lines[i] == "")
                    line = "";
                else
                    line = lines[i].strip();
                end
                if (lines[i+1] == "\n" or lines[i+1] == "")
                   line1 = "";
                else
                   line1 = lines[i+1].strip();
                end
                if (lines[i+2] == "\n" or lines[i+2] == "")
                   line2 = "";
                else
                   line2 = lines[i+2].strip();
                end
                #puts line
                if (line == start_1 and line1 == start_2 and line2 == start_3)
                   flag = "open"
                   index_start = i+3;
                   index_end   = i+3;
                end
                if (flag == "open" and line == finish_1 and line1 == finish_2 and line2 == finish_3)
                   #puts "OK1";
                   index_end   = i;
                   break;
                end
             end
    
    
             if (index_end > index_start)
                for j in (index_start ... index_end) do
                   if (lines[j] == "\n" or lines[j] == "")
                      line = "ERROR";
                   else
                      line = rule(lines[j].strip());
                   end    
            
                   if (line == "ERROR")
                      failure.push(lines[j]+"\n");
                   else
                      succeed.push(line);
                   end
                end
               #puts "Write to successful !"
               # retrun         
               #out_lines.push(succeed);
               #out_lines.push(failure);
               #return out_lines;
               container.concat(succeed)
               p "show: #{container}"
               return failure
             else        
               return nil
             end
        end #extract_ruby 
  end
end
