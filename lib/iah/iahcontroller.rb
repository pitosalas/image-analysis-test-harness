=begin
  * Name: iahcontroller.rb
  * Description: Analyze voting ballots
  * Author: Pito Salas
  * Copyright: (c) R. Pito Salas and Associates, Inc.
  * Date: January 2009
  * License: GPL

  This file is part of Ballot-Analizer

  Ballot-Analizer is free software: you can redistribute it and/or modify
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
  
 def on_init  
    @back_end = BackEnd.new(self)
    @view = View.new(self)
    @view.show(true)
  end
  
  def on_run
    @stats = {}
    @start_time = {}
    @total_ballot_scan_time = 0
    set_mode :idle
    set_app_name "BallotScanner"
    begin
      super
    rescue Exception => e
      puts e.message
      retry
    end
  end
  
  def begin_run
    set_mode :running
    @processing_thread = Thread.new do
      @back_end.start_processing  @ballots_directory
      set_mode :ready_to_run
    end
  end
  
  def stop_run
    @back_end.stop_processing
  end
  
  def set_ballots_directory dirname
    @ballots_directory = dirname
    reset_all_stats
    set_stat :ballot_count, Pathname.new(@ballots_directory).entries.length
    set_mode :ready_to_run
  end
  
  def reset_all_stats
    set_stat :ballot_count, 0
    set_stat :success_analysis, 0
    set_stat :failed_analysis, 0
    set_stat :correctly_scored, 0
  end
  
  def get_stat key
    @stats[key]
  end
  
  def set_stat key, count
    @stats[key] = count
    if @stats[:ballot_count] == 0 
      pct = ""
    else
      pct = "(#{(count * 100 / @stats[:ballot_count]).to_int }%)"
    end
    @view.set_stat key, "#{count} #{pct}"
  end
  
  def incr_stat key
    set_stat key, @stats[key] += 1
  end

#
# Closing the main view causes a clean exit to the whole application
#
  def exit_application
    @view.close
  end

#
# Called when a ballot scan is beginning by the background process
#
  def start_ballot filename
    mark_start_time(:ballot)
    @view.start_ballot filename
  end
#
# Called when ballot scan completes without throwing an error
#  
  def ballot_success
    incr_stat :success_analysis
    mark_end_time(:ballot)
  end
#
# Called when a ballot scan fails to complete
# 
  def ballot_failed
    incr_stat :failed_analysis
  end
#
# Mark start of event identified by key
# 
  def mark_start_time key
    @start_time[key] = Time.now
  end
#
# Mark end of an event identified by key
# 
  def mark_end_time key
    elapsed_time = Time.now - @start_time[key]
    if key == :ballot
      @total_ballot_scan_time += elapsed_time
      average_so_far = @total_ballot_scan_time / get_stat(:success_analysis)
      fmt_avg = sprintf("%.2f sec", average_so_far)
      @view.set_stat :time_per_ballot, fmt_avg 
    end
  end
  
#
# Change overall mode of the app
#
# :idle => nothing is happening. Cannot run yet.
# :ready_to_run => ballot directory is specified. Non zero ballots there
# :running => background processes are running. Now pause and stop commands are available
# :paused => suspended 
  def set_mode newmode
    @mode = newmode
    @view.set_mode newmode
    case newmode
    when :idle
       reset_all_stats
    end
  end
end
