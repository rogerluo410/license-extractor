require './accessor'
require 'thread/pool'
module Extractor
  class Task
     include Accessor
   
     def initialize pool_num = 1
         @queue   = []
         @pool = Thread.pool(pool_num)
     end

     def queue_empty?
         @queue.empty?
     end

     def queue_clear
         @queue.clear 
     end

     def pool_shutdown
       @pool.shutdown
       GC.start
     end



     def importQueue(file,readMethodName,mode = 0)
         queue_clear unless queue_empty?
         if mode == 1
           @queue << file
           return
         end
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
       @pool.wait(:done)
       p "exec_block memory size: #{ObjectSpace.memsize_of exec_block}"
       exec_block = WeakRef.new(exec_block)
       p "exec_block memory size: #{ObjectSpace.memsize_of exec_block}"
      end #execution

  end
end 
