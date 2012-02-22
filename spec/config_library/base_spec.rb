require 'spec_helper'

describe ConfigLibrary::Base do
  subject{ConfigLibrary::Base}
  let(:lifo_lib) {
    lib = subject.new(:lifo, first:{},second: {} )
    lib.books[:new] = {}
    lib
  }
  let(:fifo_lib) {
    lib = subject.new(:fifo, first:{},second: {})
    lib.books[:new] = {}
    lib
  }
  let(:manual_lib) {
    lib = subject.new(:manual, first:{},second: {})
    lib.books[:new] = {}
    lib
  }

  describe "#initialize(order_strategy, initial_books)" do
    describe "should raise an ArgumentError when giving improper arguments" do
      specify {lambda{subject.new(:lifo, {})}.should_not raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new(:fifo, {})}.should_not raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new(:manual, {})}.should_not raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new(:test, {})}.should raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new(nil, {})}.should raise_error(ArgumentError, /order_strategy/)}

      specify {lambda{subject.new(:lifo, [])}.should raise_error(ArgumentError, /not a kind of hash/)}
      specify {lambda{subject.new(:lifo, :hash)}.should raise_error(ArgumentError, /not a kind of hash/)}
      specify {lambda{subject.new(:lifo, "hi")}.should raise_error(ArgumentError, /not a kind of hash/)}
      specify {lambda{subject.new(:lifo, String => {})}.should raise_error(ArgumentError, /respond to #intern/)}
      specify {lambda{subject.new(:lifo, :default=> [])}.should raise_error(ArgumentError, /not a kind of hash/)}
    end

    it "should initialize properly if given correct arguments" do
      lib = subject.new(:lifo, default:{})
      lib.search_order.should == [:default]
      lib.order_strategy.should == :lifo
      lib.books.should == {default: {}}
    end

    it "should symbolize keys in the new_books hash" do
      lib = subject.new(:lifo, "default" => {})
      lib.search_order.should == [:default]
    end
  end

  describe "#add_to_order(key)" do
    it "should raise an error if given a key that's not a member of @books" do
      lambda{ lifo_lib.add_to_search_order(:test)}.should raise_error(ArgumentError, /not a valid book/)
    end
    context "when order_strategy = :lifo" do
      specify {lifo_lib.add_to_search_order(:new).should == [:new,:second,:first]}
    end
    context "when order_strategy = :fifo" do
      specify {fifo_lib.add_to_search_order(:new).should == [:first,:second,:new]}
    end
    context "when order_strategy = :manual" do
      specify {manual_lib.add_to_search_order(:new).should == []}
    end
  end

  describe "#has_key?(key)" do
    it "should return false if no book has the specified key" do
      fifo_lib.has_key?(:batman).should be_false
    end

    it "should return true if any of the books has the specified key" do
      fifo_lib.books[:first][:batman] = :robin
      fifo_lib.has_key?(:batman).should be_true
    end
  end

  describe "#books_with_key?(key)" do
    it "should return an empty array if no book has the specified key" do
      fifo_lib.books_with_key(:batman).should == []
    end

    it "should return an array of book names which have the specified key" do
      fifo_lib.books[:first][:batman] = :robin
      fifo_lib.books[:second][:batman] = :robin
      fifo_lib.books_with_key(:batman).should == [:first, :second]
    end
  end

  describe "#fetch(key)" do
    it "should return nil if key is not present, and no default argument given" do
      fifo_lib.fetch(:batman).should be_nil
    end

    it "should return the default parameter if key is not present and default argument given" do
      fifo_lib.fetch(:batman) { :bat_signal }.should == :bat_signal
    end

    it "should return the value from the first book that has the key present" do
      fifo_lib.books[:first][:robin] = "Dick Grayson"
      fifo_lib.books[:second][:robin] = "Jason Todd"
      fifo_lib.fetch(:robin).should == "Dick Grayson"
    end

    context "with symbol keys" do
      it "should return the same value regardless of whether the key is a string or a symbol" do
        fifo_lib.books[:first][:robin] = "Dick Grayson"
        fifo_lib.books[:second][:robin] = "Jason Todd"
        fifo_lib.fetch("robin").should == "Dick Grayson"
      end
    end

    context "with string keys" do
      it "should return the same value regardless of whether the key is a string or a symbol" do
        fifo_lib.books[:first]["robin"] = "Dick Grayson"
        fifo_lib.books[:second]["robin"] = "Jason Todd"
        fifo_lib.fetch(:robin).should == "Dick Grayson"
      end
    end

    it "should return a hash" do
      fifo_lib.books[:first][:robin] = { name: "Dick Grayson" }
      fifo_lib.fetch(:robin).should == { name: "Dick Grayson" }
    end
  end

  describe "#fetch_all(key)" do
    it "should return an empty array if key is not present" do
      fifo_lib.fetch_all(:batman).should == []
    end

    it "should return the a list of values made from every book that has the key present" do
      fifo_lib.books[:first][:robin] = "Dick Grayson"
      fifo_lib.books[:second][:robin] = "Jason Todd"
      fifo_lib.fetch_all(:robin).should == ["Dick Grayson", "Jason Todd"]
    end
  end

  describe "#has_key_chain?(key_chain)" do
    it "should return false if given a key_chain which does not exist" do
      fifo_lib.has_key_chain?(:batman).should be_false
    end

    it "should return true if given a key_chain with 1 element that exists" do
      fifo_lib.books[:first][:robin] = "Dick Grayson"
      fifo_lib.has_key_chain?(:robin).should be_true
    end

    it "should return true if given a key_chain with more than 1 element that exists" do
      fifo_lib.books[:first][:robin] = {first: "Dick Grayson"}
      fifo_lib.books[:second][:sidekick] = {robin: {second: "Jason Todd", third: "Tim Drake"}}
      fifo_lib.has_key_chain?(:robin, :first).should be_true
      fifo_lib.has_key_chain?(:sidekick, :robin, :third).should be_true
    end
  end

  describe "#fetch_chain(key_chain)" do
    it "should fetch the value at the end of the chain in the first book that has it." do
      fifo_lib.books[:first][:robin] = {one: "Dick Grayson"}
      fifo_lib.fetch_chain(:robin, :one).should == "Dick Grayson"
      fifo_lib.books[:second][:sidekick] = {robin: {second: "Jason Todd", third: "Tim Drake"}}
      fifo_lib.fetch_chain(:sidekick, :robin, :third).should == "Tim Drake"
    end
    it "should return nil if the key chain doesn't exist" do
      fifo_lib.fetch_chain(:sidekick, :batgirl).should be_nil
    end
    it "should return the result of a default block if no key is found" do
      fifo_lib.fetch_chain(:sidekick) { :default }.should == :default
    end
  end

  describe "#fetch_all(key_chain)" do
    it "should fetch the value at end of the chain for every book that has it." do
      fifo_lib.books[:first][:sidekick] = {robin: {name: "Dick Grayson"}}
      fifo_lib.books[:second][:sidekick] = {robin: {name: "Jason Todd"}}
      fifo_lib.fetch_all_chain(:sidekick, :robin, :name).should == ["Dick Grayson", "Jason Todd"]
    end
    it "should return nil if the key chain doesn't exist" do
      fifo_lib.fetch_chain(:sidekick, :batgirl).should be_nil
    end
    it "should return the result of a default block if no key is found" do
      fifo_lib.fetch_chain(:sidekick, :batgirl) { :default }.should == :default
    end
  end

  describe "#config" do
    specify { fifo_lib.config.should be_a ConfigLibrary::MethodChain }
  end
end
