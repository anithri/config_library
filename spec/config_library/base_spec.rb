require 'spec_helper'

describe ConfigLibrary::Base do
  subject{ConfigLibrary::Base}
  let(:default) {subject.new}
  let(:batman) do
    l = subject.new
    COMMON_BATMAN_HASH.each_pair do |k,v|
      l.add_new_book(k,v)
    end
    l
  end

  describe "#add_new_books(*args)" do
    it "take a list of strings or symbols" do
      default.add_new_books(:a,'b',:c)
      default.books.keys.should =~ [:a,:b,:c]
    end

    it "takes a hash" do
      default.add_new_books(foo:{a:1,b:3}, bar: {a: 4,c: 3})
      default.books.keys.should =~ [:foo, :bar]
      default.books[:foo][[:a]].should == 1
      default.books[:bar][[:c]].should == 3
    end

    it "takes arrays of keys and hashes" do
      default.add_new_books([:a,'b',{:c => {}} ])
      default.books.keys.should =~ [:a,:b,:c]
    end
  end

  describe "#_mk_new_hash(old_hash = nil)" do

    it "should flatten a hash into a single structure with arrays for keys" do
      hash = {:a => 1, :b => 2}
      default._mk_new_hash().should == {}


      result = default._mk_new_hash(hash)
      result.should have_key([:a])
      result.should have_key([:b])

      result[[:a]].should == 1
      result[[:b]].should == 2

      deep_hash = {:foo => hash.dup, :bar => hash.dup}

      result = default._mk_new_hash(deep_hash)
      result.should have_key([:foo,:a])
      result.should have_key([:bar,:b])

      result = default._mk_new_hash(COMMON_BATMAN_HASH)
      result.should have_key([:golden_age, :batman, :name])
      result.should have_key([:silver_age, :batman, :villains, :poison_ivy])

      hash =  {foo: 3, bar: "High", baz: { system: "linux", user: "me"}}
      result = default._mk_new_hash(hash)
      warn result.inspect

    end
  end

  describe "#fetch(*key_chain)" do
    it "should fetch the proper key" do
      batman.fetch(:batman, :sidekicks, :robin).should == "Jason Todd"
    end
  end

  describe "#fetch_all(*key_chain)" do
    it "should fetch the proper keys" do
      batman.fetch_all(:batman, :sidekicks, :robin).should == ["Jason Todd","Dick Grayson"]
    end
  end

  describe "#fetch_all_as_hash(*key_chain)" do
    it "should fetch the proper keys" do
      batman.fetch_all_as_hash(:batman, :sidekicks, :robin).should == {golden_age: "Dick Grayson", silver_age: nil, bronze_age: "Jason Todd"}
    end
  end

  describe "#keys_for(*key_chain)" do
    it "should return the proper key list" do
      batman.keys_for(:batman, :sidekicks).should =~ [:robin, :bat_girl, :nightwing]
    end

    it "should return an empty list if no keys are found" do
      batman.keys_for(:wonder_woman).should == []
      batman.keys_for(:batman, :name).should == []
    end
  end

  describe "#deep_keys_for(*key_chain)" do
    it "should return the proper key list" do
      batman.deep_keys_for(:batman, :sidekicks).should =~ [[:robin], [:bat_girl], [:nightwing]]
      batman.deep_keys_for(:green_arrow).should == [[:sidekicks, :speedy]]
    end

    it "should return an empty list if no keys are found" do
      batman.keys_for(:wonder_woman).should == []
      batman.keys_for(:batman, :name).should == []
    end
  end

  describe "#assign_to(*key_chain,value)" do
    it "should assign the value to the proper book" do
      batman.add_new_book(:runtime)
      batman.assign_to(:batman, :sidekicks, :robin, "Tim Drake")
      batman.books[:runtime].should == {[:batman, :sidekicks, :robin] => "Tim Drake"}
      batman.fetch(:batman, :sidekicks, :robin).should == "Tim Drake"
      batman.fetch_all(:batman, :sidekicks, :robin).should ==  ["Tim Drake", "Jason Todd","Dick Grayson"]
    end

  end

  describe "#books_with(*key_chain)" do
    it "should return an array of book names" do
      batman.books_with(:wonder_woman).should == []
      batman.books_with(:batman, :sidekicks, :robin).should == [:bronze_age, :golden_age]
    end
  end

  describe "#books_with_value(*key_chain, value)" do
    it "should return an array of book names that have a key chain with a specific value" do
      batman.books_with_value(:batman, :sidekicks, :robin, "Jason Todd").should == [:bronze_age]
    end
  end

  describe "#has_key(*key_chain)" do
    it "should be true if the chain has a value or has sub keys" do
      batman.has_key?(:batman, :sidekicks).should be_true
      batman.has_key?(:batman, :villains, :joker).should be_true
    end

    it "should be false if the chain has no value or subkeys" do
      batman.has_key?(:wonder_woman, :gadgets).should be_false
    end
  end

  describe "#fetch_hash(*key_chain = [])" do
    it "should return an empty hash for a nonexistent keychain" do
      default.fetch_hash(:batman,:sidekicks).should == {}
    end
    it "should return a hash" do
      default.add_new_books(foo:{a:1,b:3}, bar: {a: 6,c: {d: 5}})
      default.fetch_hash(:c).should == {d: 5}
      batman.fetch_hash(:batman, :sidekicks).should be_a Hash
      batman.fetch_hash(:batman, :sidekicks).keys.should =~ [:robin, :nightwing, :bat_girl]
    end
    it "should return a deep hash" do
      batman.fetch_hash(:green_arrow)[:sidekicks][:speedy].should == "Roy Harper"
    end
  end
end
