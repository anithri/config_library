require "spec_helper"

describe ConfigLibrary::Settings do
  subject{ConfigLibrary::Settings}
  let(:default_settings) { subject.new() }

  describe "#initialize(*opts)" do
    it "should initialize to defaults when no options are present" do
      default_settings.should be_a subject
      default_settings.assign_ok.should be_true
      default_settings.new_book_strategy.call.should == {}
    end

    it "should take a hash as opts and populate settings with it's values" do
      new_settings = subject.new(assign_ok: false, search_order_strategy: :fifo)
      new_settings.assign_ok?.should be_false
      new_settings.instance_variable_get(:@search_order_strategy).should == :fifo
    end

    describe "should raise an ArgumentError if given invalid settings" do
      context "with an unknown setting type" do
        specify { lambda { subject.new(bad: true)}.should raise_error ArgumentError, /bad/}
      end
      context "with a bad :search_order_strategy" do
        specify {lambda { subject.new(search_order_strategy: :foo_bar)}.should raise_error ArgumentError, /foo_bar/}
      end
      context "when a strategy gets a non-callable value" do
        specify { lambda { subject.new(new_book_strategy: false)}.should raise_error ArgumentError, /not callable/}
        specify { lambda { subject.new(assign_to_book_strategy: false)}.should raise_error ArgumentError,
                                                                                          /not callable/}
      end
      context "when a search_order_strategy is given" do
        specify { lambda { subject.new(search_order_strategy: "poof")}.should raise_error ArgumentError, /poof/}
      end
    end
  end

  describe "#is_valid_search_order_strategy(new_strategy)" do
    it "should be true for any string or symbol which is a method in ConfigLibrary::SearchOrderStrategies" do
      default_settings.is_valid_search_order_strategy?(:manual).should be_true
      default_settings.is_valid_search_order_strategy?("fifo").should be_true
      default_settings.is_valid_search_order_strategy?(:lifo).should be_true
      module ConfigLibrary::SearchOrderStrategies; def another_one; end; end;
      default_settings.is_valid_search_order_strategy?("another_one").should be_true
    end
    it "should be false for any other value" do
      default_settings.is_valid_search_order_strategy?("test").should be_false
      default_settings.is_valid_search_order_strategy?(:junk).should be_false
      default_settings.is_valid_search_order_strategy?(:describe).should be_false
    end
  end

  describe "Should hvae predicate methods for @assign_ok and @assign_deep_ok" do
    specify { default_settings.assign_ok?.should be_true }
    specify { default_settings.assign_deep_ok?.should be_true }
  end

  describe "@assign_to_book_strategy" do
    it "should should assign to the first book in sort order by default" do
      default_settings.assign_to_book_strategy.call([:first, :second, :third]).should == :first
    end

  end
end