require './accessor'
module Extractor
  class Task
     include Accessor
   
     def initialize
         @queue   = []
         @threads = [] 
     end

     def queue_empty?
         @queue.empty?
     end

     def queue_clear
         @queue.clear 
     end 

     def importQueue(file,readMethodName)
         queue_clear unless queue_empty?  
         self.send readMethodName.to_sym,file,@queue       
     end

     def execution(exec_block)
         @queue.each do | task |
            @threads << Thread.new do
                exec_block.call(task)
            end
         end
         @threads.each { | t | t.join }
     end    
  end
end 
