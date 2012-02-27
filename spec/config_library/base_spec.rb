require 'spec_helper'

describe ConfigLibrary::Base do
  subject{ConfigLibrary::Base}
  let(:lifo_lib) {
    lib = subject.new(first:{},second: {})
    lib.books[:new] = {}
    lib
  }
  let(:fifo_lib) {
    lib = subject.new({first:{},second: {}}, search_order_strategy: :fifo)
    lib.books[:new] = {}
    lib
  }
  let(:manual_lib) {
    lib = subject.new({first:{},second: {}},search_order_strategy: :manual)
    lib.books[:new] = {}
    lib
  }

  describe "#initialize(order_strategy, initial_books)" do
    describe "should raise an ArgumentError when giving improper arguments" do
      specify {lambda{subject.new({}, search_order_strategy: :lifo)}.should_not raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new({}, search_order_strategy: :fifo)}.should_not raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new({}, search_order_strategy: :manual)}.should_not raise_error(ArgumentError, /order_strategy/)}
      specify {lambda{subject.new({}, search_order_strategy: :riddle)}.should raise_error(ArgumentError, /riddle/)}

      specify {lambda{subject.new([])}.should raise_error(ArgumentError, /not a kind of hash/)}
      specify {lambda{subject.new(:hash)}.should raise_error(ArgumentError, /not a kind of hash/)}
      specify {lambda{subject.new("hi")}.should raise_error(ArgumentError, /not a kind of hash/)}
      specify {lambda{subject.new(String => {})}.should raise_error(ArgumentError, /respond to #intern/)}
      specify {lambda{subject.new(:default=> [])}.should raise_error(ArgumentError, /must be a kind of hash/)}
    end

    it "should initialize properly if given correct arguments" do
      lib = subject.new(default:{})
      lib.search_order.should == [:default]
      lib.settings.instance_variable_get(:@search_order_strategy).should == :lifo
      lib.books.should == {default: {}}
    end

    it "should symbolize keys in the new_books hash" do
      lib = subject.new("default" => {})
      lib.search_order.should == [:default]
    end
  end

  describe "#new_book_strategy" do
    it "should create new books with the given strategy." do
      lifo_lib.settings.new_book_strategy = lambda{{foo: :bar}}
      lifo_lib.add_book(:baz)
      lifo_lib.books[:baz].should == {foo: :bar}
    end
  end

  describe "#book_to_assign_to" do
    context "when given an invalid argument" do
      it "should raise an argument error is given anything but a symbol" do
        lambda{lifo_lib.book_to_assign_to=123}.should raise_error(ArgumentError,/symbol.+book name/)
        lambda{lifo_lib.book_to_assign_to="hi"}.should raise_error(ArgumentError,/symbol.+book name/)
      end
      it "should raise an argument error if given a symbol that is not a key in @books" do
        lambda{lifo_lib.book_to_assign_to=:foo_bar_baz}.should raise_error(ArgumentError,/book named.+foo_bar_baz/)
      end
    end
    it "should default to the first name in the @search_order list" do
      lifo_lib.book_to_assign_to.should == :second
      fifo_lib.book_to_assign_to.should == :first
    end
    it "should return the valid value set" do
      fifo_lib.book_to_assign_to= :second
      fifo_lib.book_to_assign_to.should == :second
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

  describe "#assign_to(keychain,value)" do
    let(:batman_lib) {subject.new(COMMON_BATMAN_HASH)}
    let(:assignment_error){ConfigLibrary::AssignmentError}
    context "when @assign_ok is false" do
      it "should raise an AssignmentError when attempting to assign anything" do
        batman_lib.settings.assign_ok = false
        lambda{ batman_lib.assign_to(:foo, :bar, :baz)}.should raise_error assignment_error, /not allowed to assign/
        lambda{ batman_lib.assign_to(:batman, :name, "Dick Grayson")}.should raise_error assignment_error, /not allowed to assign/
      end
    end
    context "when @assign_ok is true" do
      context "when @assign_over_any is false" do
        it "should raise an AssignmentError when the key_chain already exists" do
          batman_lib.settings.assign_over_any = false
          lambda{ batman_lib.assign_to(:batman, :name, "Dick Grayson")}.should raise_error(assignment_error, /not allowed to replace existing values/)
        end
      end
      context "when @assign_over_any is true" do
        context "when @assign_over_hash is false" do
          it "should raise an AssignmentError when the key already exists, but is a hash" do
            batman_lib.settings.assign_over_hash = false
            lambda{ batman_lib.assign_to(:batman, :sidekicks, "none")}.should raise_error(assignment_error, /not allowed to replace existing hash/)
          end
          it "should assign a value to an existing hash"
        end
        context "when @assign_over_hash is true" do
          it "should replace an existing hash with a new value"
        end
      end

      context "when @create_deep is false" do
        it "should raise an AssignmentError if parts of the key_chain do not exist"
      end

      context "when @create_deep is true" do
        it "should create hashes as needed, and assign the value to the deepest one"
      end
    end
  end

  describe "#_hash_for_chain(target_hash, keys_to_find, used_keys = [])", :focus do
    it "return the target_hash and 2 empty arrays if passed an empty keys_to_find" do
      results = manual_lib._hash_for_chain(COMMON_BATMAN_HASH, [])
      results[0].should == COMMON_BATMAN_HASH
      results[1].should == []
      results[2].should == []
    end

    it "return the target_hash, the existing_key_chain, and an empty array if passed a keychain that starts with a non existent key" do
      results = manual_lib._hash_for_chain(COMMON_BATMAN_HASH, [:foo])
      results[0].should == COMMON_BATMAN_HASH
      results[1].should == [:foo]
      results[2].should == []

      results = manual_lib._hash_for_chain(COMMON_BATMAN_HASH, [:foo, :bar, :baz])
      results[0].should == COMMON_BATMAN_HASH
      results[1].should == [:foo, :bar, :baz]
      results[2].should == []
    end

    it "should return the first hash that does not have the next key" do

      results = manual_lib._hash_for_chain(COMMON_BATMAN_HASH, [:golden_age, :flash])
      warn results
      results[0].should be_a(Hash)
      results[0][:batman][:name].should == "Bruce Wayne"
      results[1].should == [:flash]
      results[2].should == [:golden_age]

      results = manual_lib._hash_for_chain(COMMON_BATMAN_HASH, [:golden_age, :batman, :gadgets, :batmobile])
      results[0].should be_a(Hash)
      results[0][:name].should == "Bruce Wayne"
      results[1].should == [:gadgets, :batmobile]
      results[2].should == [:golden_age, :batman]

      results = manual_lib._hash_for_chain(COMMON_BATMAN_HASH, [:golden_age, :batman, :name])
      results[0].should be_a(Hash)
      results[0][:name].should == "Bruce Wayne"
      results[1].should == [:name]
      results[2].should == [:golden_age, :batman]
    end
  end
end
