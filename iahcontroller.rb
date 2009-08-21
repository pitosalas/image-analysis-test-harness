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

class Controller < ::Wx::App
  
  def on_init  
    @back_end = BackEnd.new(self)
    @view = View.new(self)
    @view.show(true)
  end
  
  def begin_run
    @back_end.start_processing
  end
  
  def stop_run
    @back_end.stop_processing
  end
  
  def set_ballots_directory path
    @back_end.set_ballots_directory path
  end
  
  def set_ballot_count cnt
    @ballot_count = cnt
    @view.show_ballot_count "#{cnt} (100%)"
  end
 
end

    
