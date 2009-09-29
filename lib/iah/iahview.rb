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

class View < ::Wx::Frame
  def initialize(my_controller)
    super(nil, -1, "TrustTheVote Image Processing",
        :style => (Wx::DEFAULT_FRAME_STYLE & ~ (Wx::RESIZE_BORDER|Wx::RESIZE_BOX|Wx::MAXIMIZE_BOX)) | Wx::TAB_TRAVERSAL,
        :size => [550,350]
    )
    @controller = my_controller
    
    centre(Wx::BOTH)
    setup_controls
    connect_events
  end
  
  def setup_controls
    wizard_pane
    results_table_pane
    buttons_pane
  end
  
  def buttons_pane
    @pause_button = create_button('Pause')
    @stop_button = create_button('Stop')
    @reset_button = create_button('Reset')
    @quit_button = create_button('Quit')
    
    add_button_to_button_pane(@pause_button)
    add_button_to_button_pane(@stop_button)
    add_button_to_button_pane(@reset_button)
    add_button_to_button_pane(@quit_button)
  end
  
  def create_button(label)
    Wx::Button.new(frame_panel, :label => label, :size =>[70, 30])
  end
  
  def add_button_to_button_pane(button)
    button_pane_sizer.add_item(button, :proportion => 0, :flag => Wx::RIGHT | Wx::ALIGN_RIGHT, :border => 10)
  end
  
  def wizard_pane
    @sel_ballot_folder = Wx::Button.new(frame_panel, :label => 'select ballot folder', :flag => Wx::EXPAND)
    @load_ground_truth = Wx::Button.new(frame_panel, :label => 'load ground truth', :flag => Wx::EXPAND)
    @select_algorithm = Wx::Button.new(frame_panel, :label => 'select algorithm', :flag => Wx::EXPAND)
    @begin_run = Wx::Button.new(frame_panel, :label => 'begin run', :flag => Wx::EXPAND)

    
    @show_heads_up = Wx::CheckBox.new(frame_panel, -1,  "show headsup display")
    @show_log_output = Wx::CheckBox.new(frame_panel, -1,  "show logging output")
    
    add_wizard_button("one.gif", @sel_ballot_folder)
    add_wizard_button("two.gif", @load_ground_truth)
    add_wizard_button("three.gif", @select_algorithm)
    add_wizard_button("four.gif", @begin_run)

    wizard_pane_sizer.add_spacer(30)
    wizard_pane_sizer.add_item(@show_heads_up, :flag => Wx::BOTTOM, :border => 5)
    wizard_pane_sizer.add_item(@show_log_output, :flag => Wx::BOTTOM, :border => 15)
  end
  
  def wizard_img_control(filename)
    bmp_file = File.join( File.dirname(__FILE__), '../../images', filename)
    bmp = Wx::Bitmap.new(bmp_file, Wx::BITMAP_TYPE_GIF)
    Wx::BitmapButton.new(frame_panel, 0, :bitmap => bmp, :style => Wx::NO_BORDER)
  end
  
  def add_wizard_button giffile, actual_button
    fancy = Wx::HBoxSizer.new
    fancy.add wizard_img_control(giffile)
    fancy.add_item actual_button, :flag => Wx::ALIGN_CENTRE
    wizard_pane_sizer.add_item(fancy, :flag => Wx::BOTTOM | Wx::ALIGN_LEFT, :border => 0)
  end
  
  def results_table_pane
    @total_ballots = result_value("Total Ballots:")
    @cant_analyze = result_value("Can't Analyze:")
    @analyzed = result_value("Analyzed:")
    @correctly_scored = result_value("Correctly Scored:")
    @time_per_ballot = result_value("Time per Ballot:")
    @time_overall = result_value("Time Overall:")
    @current_ballot = result_value("Current Ballot:")
  end
  
  def result_value label, initial=""
    label_box = Wx::StaticText.new frame_panel, -1, label
    text_box = Wx::StaticText.new frame_panel, -1, initial
    results_pane_sizer.add_item label_box, :proportion => 1, :flag => Wx::EXPAND
    results_pane_sizer.add_item text_box, :proportion => 1, :flag => Wx::EXPAND | Wx::ALL, :border => 3
    text_box
  end
  
  def frame_panel
    @frame_panel ||= (
      marginpanel = Wx::Panel.new self
      vbox = Wx::VBoxSizer.new
      marginpanel.sizer = vbox
      framepanel = Wx::Panel.new(marginpanel, -1)
      vbox.add_item framepanel, :proportion => 1, :flag => Wx::ALL | Wx::EXPAND, :border => 20
      framepanel
    )
  end
  
  def frame_sizer
    @frame_sizer ||= (
      sizer = Wx::VBoxSizer.new
      frame_panel.sizer = sizer
      sizer
    )
  end
  
  def button_pane_sizer
    @button_pane_sizer ||= (
      the_sizer = Wx::HBoxSizer.new
      frame_sizer.add_item the_sizer, :proportion => 0, :flag => Wx::ALIGN_RIGHT | Wx::ALIGN_BOTTOM
      the_sizer
    )
  end
  
  def top_pane_sizer
    @top_pane_sizer ||= (
      top_pane_szr = Wx::HBoxSizer.new
      frame_sizer.add_item top_pane_szr, :flag => Wx::EXPAND, :proportion => 1
      top_pane_szr
    )
  end
  
  def wizard_pane_sizer
    @wizard_pane_sizer ||= (
      wiz_pane_sz = Wx::VBoxSizer.new
      top_pane_sizer.add_item wiz_pane_sz, :proportion => 0, :flag => Wx::ALIGN_LEFT
      wiz_pane_sz
    )
  end
  
  def results_pane_sizer
      @results_pane_sizer ||= (
      res_pane_sz = Wx::FlexGridSizer.new(6, 2, 0, 0) # rows, columns, vspace, hspace
      top_pane_sizer.add_item res_pane_sz, :proportion => 1, :border => 60, :flag => Wx::LEFT | Wx::EXPAND | Wx::ALIGN_RIGHT
      res_pane_sz
    )
  end
  
  def connect_events
    evt_button(@stop_button)        { @controller.stop_run }
    evt_button(@begin_run)          { @controller.begin_run }
    evt_button(@sel_ballot_folder)  { get_ballots_directory }
    evt_button(@quit_button)        { @controller.exit_application}
  end
  
  def get_ballots_directory
    dialog = Wx::DirDialog.new(self, "Select Ballots Directory", Dir.pwd)
    if dialog.show_modal() == Wx::ID_OK
      @controller.set_ballots_directory dialog.get_path
    end
  end

#
# Update one of the various statistics in the dialog based on the key parameter
#
  def set_stat key, string
    case key
    when :ballot_count
      @total_ballots.label = string
    when :success_analysis
      @analyzed.label = string
    when :failed_analysis
      @cant_analyze.label = string
    when :correctly_scored
      @correctly_scored.label = string
    when :time_per_ballot
      @time_per_ballot.label = string
    end
  end
  
#
# Update display to show that we are starting a new ballot
#
  def start_ballot str
    @current_ballot.label = str
  end

# 
# update view to reflect mode changes. Enable/disable controls, etc.
#  
  def set_mode newmode
    case newmode
    when :idle
      @begin_run.enable false
      @quit_button.enable true
      @pause_button.enable false
      @sel_ballot_folder.enable true
    when :ready_to_run
      @begin_run.enable true
      @quit_button.enable true
      @pause_button.enable false
      @sel_ballot_folder.enable true
    when :running
      @sel_ballot_folder.enable false
      @pause_button.enable true
      @quit_button.enable true
      @sel_ballot_folder.enable false
      @begin_run.enable false
    when :paused
      @begin_run.enable true
      @sel_ballot_folder.enable false
      @pause_button.enable false
      @quit_button.enable true
      @sel_ballot_folder.enable true
    when :finished
      @begin_run.enable true
      @sel_ballot_folder.enable false
      @pause_button.enable false
    end
  end
end
