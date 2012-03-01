require "spec_helper"

describe ConfigLibrary::MethodChain do
  subject{ConfigLibrary::MethodChain}
  let(:simple_chain) {subject.new("simple", :batman )}
  let(:simple_library) {ConfigLibrary::Base.new(COMMON_BATMAN_HASH)}
  let(:batman_chain) {subject.new(ConfigLibrary::Base.new(COMMON_BATMAN_HASH))}

  describe "#initialize" do
    it "it should set library and key_chain variables" do
      simple_chain = subject.new("simple", :batman)
      simple_chain.instance_variable_get(:@library).should == "simple"
      simple_chain.instance_variable_get(:@key_chain).should == [:batman]
      simple_chain.instance_variable_get(:@still_possible).should == true
    end
  end

  describe "OP_LOOKUPS"  do
    it "should have a method for every value in OP_LOOKUPS" do
      subject::OP_LOOKUPS.each_value do |method_sym|
        subject.instance_methods.should include(method_sym)
      end
    end
  end

  describe "#method_missing(name_sym, *args)" do
    it "should call the method defined in OP_LOOKUPS" do
      simple_chain.should_receive(:_plain_element).and_return(true)
      simple_chain.joker

      simple_chain.should_receive(:_bang_element).and_return(true)
      simple_chain.joker!

      simple_chain.should_receive(:_assign_element).and_return(true)
      simple_chain.joker= nil
    end
  end

  describe "#_plain_element(name_sym, op, *args, &block)" do

    it "should return the value if called with a single top level element"do
      batman_chain.library.assign_to(:publisher, :dc)
      batman_chain.library.fetch(:publisher).should == :dc
      batman_chain.publisher.should == :dc
    end
    it "should return the value if called with a keychain" do
      batman_chain.batman.villains.riddler.should == "Edward E Nigma"
    end

    it "should return itself if the requested element is a hash" do
      batman_chain.batman.villains.should === batman_chain
      batman_chain.instance_variable_get(:@key_chain).should == [:batman, :villains]
    end

    it "should raise NoMethodFound if called with key that doesn't exist'" do
      lambda{batman_chain.batman.villains.catwoman}.should raise_error NoMethodError, /catwoman/
    end

  end

  describe "#_bang_element(name_sym, op, *args, &block)" do
    it "should return nil if no element found" do
      batman_chain.batman.villains.catwoman!.should be_nil
    end

    it "should return the value if a non-hash element is found" do
      batman_chain.batman.villains.riddler!.should == "Edward E Nigma"
    end

    it "should return a hash if the requested element is a hash" do
      a = batman_chain.batman.villains!
      warn a.inspect
      a.keys.should include(:joker)
    end
  end

  describe "#_assign_element(name_sym, op, *args, &block)" do
    it "should call the library's _assign_element method passing keychain and original arguments'" do
      batman_chain.library.should_receive(:assign_to).with([:batman, :villains, :catwoman],"Selina Kyle")
      batman_chain.batman.villains.catwoman = "Selina Kyle"
    end

    it "should assign a an empty hash to a key_chain" do
      batman_chain.library.should_receive(:assign_to).with([:batman, :gadgets],{})
      batman_chain.batman.gadgets = {}
    end
  end
end
