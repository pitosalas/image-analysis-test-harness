=begin
  * Name: Ballot-analyzer
  * Description: Analyze voting ballots
  * Author: Pito Salas
  * Copyright: (c) R. Pito Salas and Associates, Inc.
  * Date: January 2009
  * License: GPL

  This file is part of Ballot-analyzer.

  Ballot-analyzer is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Ballot-analyzer is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ballot-analyzer.  If not, see <http://www.gnu.org/licenses/>.

  require "ruby-debug"
  Debugger.settings[:autolist] = 1 # list nearby lines on stop
  Debugger.settings[:autoeval] = 1
  Debugger.start
=end
require 'pathname'

class BackEnd
  
  def initialize(contr)
    @controller = contr
  end
  
  def process_line line
    case line
      when /^ballot ("(.+)"|(\S+))$/
        @controller.start_ballot $1
      when /^success$/
        @controller.incr_stat :success_analysis
      when /^failure$/
        @controller.incr_stat :failed_analysis
      else
        puts "unexpected return from sub process: #{line}"
    end
  end
  
  def start_processing dir
    open("|-", "r") do |worker|
      if worker
        # here we are in the harness
        line_counter = 0
        worker.each_line do |line|
          line_counter = line_counter + 1
          process_line(line.chomp)
        end
        puts "workers end"
      else
        # here we are in child thread
        exec("/mydev/ballot-analizer/ba_run.rb", "-d", dir, "-u")
      end
    end    
  end
  
  def stop_processing
    
  end
  
  def pause_processing
    
  end
  
  
  
end
