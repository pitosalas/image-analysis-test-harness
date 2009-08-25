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

class Controller < ::Wx::App
  
  attr_reader :total_ballot_count
  
  def on_init  
    @back_end = BackEnd.new(self)
    @view = View.new(self)
    @view.show(true)
   
  end
  
  def begin_run
    @processing_thread = Thread.new do
      @back_end.start_processing
     end
  end
  
  def stop_run
    @back_end.stop_processing
  end
    
  def set_ballot_count cnt
    @ballot_count = cnt
    @view.show_ballot_count "#{cnt} (100%)"
  end
  
  def set_ballots_directory dirname
    @ballots_directory = dirname
    @total_number_of_ballots = Pathname.new(@ballots_directory).entries.length
    @view.show_ballot_count "#{@total_number_of_ballots}"
  end
 
end

    
