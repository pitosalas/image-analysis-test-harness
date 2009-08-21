require "rubygems"
require "test/unit"
require "shoulda"
require "iatestharness"
class Test_IATest_harness < Test::Unit::TestCase
  context "If shoulda is properly set up then" do
    setup do
      @th = IATestHarness.new
    end
    
    should "succeed" do
      assert_equal 1,1
    end
  end
end
