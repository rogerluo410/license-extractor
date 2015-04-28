require './accessor'
require 'thread/pool'
module Extractor
  class Task
     include Accessor
   
     def initialize
         @queue   = []
         @pool = Thread.pool(20)
     end

     def queue_empty?
         @queue.empty?
     end

     def queue_clear
         @queue.clear 
     end

     def pool_shutdown
       @pool.shutdown
     end

     def importQueue(file,readMethodName)
         queue_clear unless queue_empty?  
         self.send readMethodName.to_sym,file,@queue       
     end

     def execution(exec_block)
=begin  so many threads created for this approach!
         @queue.each do | task |

            @threads << Thread.new do
                exec_block.call(task)
            end
         end
         @threads.each { | t | t.join }
=end
=begin
       for i in (0...10) do

         Thread.new(i) do | i |
           @queue.each_with_index do | task,index |
             if index % 10 == i
              exec_block.call(task)
             end
         end
       end
         end
=end
=begin
         @pool.process {
         #  sleep 2
           p "in thread pool"
           @queue.each do | task |
             exec_block.call(task)
           end
         }
         @pool.shutdown
=end
       @queue.each do | task |
         @pool.process {
           exec_block.call(task)
           sleep 1
         }
       end
       @pool.wait

      end #execution

  end
end 
