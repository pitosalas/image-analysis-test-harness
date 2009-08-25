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
  
  def start_processing
    open("|-", "r") do |worker|
      if worker
        # here we are in the harness
        i = 0
        worker.each_line do |line|
          @controller.set_ballot_count i
          i = i+1
        end
      else
        # here we are in child thread
        exec("./iacommand.rb", "-t")
      end
    end    
  end
    
    def stop_processing
    end
  end
