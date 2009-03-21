require File.dirname(__FILE__) + '/spec_helper'

describe "merb_logging_ext" do
  describe Colorful do
    before(:all) do
      @show_all = false
    end
    def puts_if_allowed(target)
      puts target if @show_all
    end
    it "red" do
      puts_if_allowed Colorful.red("red message")
    end
    it "yellow" do
      puts_if_allowed Colorful.yellow("yellow message")
    end
    it "blue" do
      puts_if_allowed Colorful.blue("blue message")
    end
    it "green" do
      puts_if_allowed Colorful.green("red message")
    end
    it "magenta" do
      puts_if_allowed Colorful.magenta("magenta message")
    end
  end
end
