require "spec_helper"

describe ConfigLibrary::MethodChain do
  subject{ConfigLibrary::MethodChain}
  let(:simple_chain) {subject.new("simple", :batman )}
  let(:simple_library) {ConfigLibrary::Base.new(:lifo,COMMON_BATMAN_HASH)}
  let(:batman_chain) {subject.new(ConfigLibrary::Base.new(:lifo,COMMON_BATMAN_HASH))}

  describe "#initialize" do
    it "it should set library and key_chain variables" do
      simple_chain = subject.new("simple", :batman)

      simple_chain.library.should == "simple"
      simple_chain._key_chain.should == [:batman]
    end
  end

  describe "OP_LOOKUPS" do
    it "should have a key for evey character in ConfigLibrary::ALLOWED_KEY_ENDINGS plus nil" do
      ConfigLibrary::ALLOWED_KEY_ENDINGS.split("").each do |op|
        subject::OP_LOOKUPS.should include(op)
      end
      subject::OP_LOOKUPS.should have_key(nil)
    end

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
    it "should return nil if no element found" do
      result = batman_chain.batman.villains.catwoman
      result.should be_a ConfigLibrary::NullResult
      result.should be_nil
      result.inspect.should match(/ok for .batman.villains, nil on .catwoman, no callers/)
    end

    it "should return the value if a non-hash element is found" do
      batman_chain.batman.villains.riddler.should == "Edward E Nigma"
    end

    it "should return itself if the requested element is a hash" do
      batman_chain.batman.villains.should === batman_chain
      batman_chain._key_chain.should == %w(batman villains)
    end
  end

  describe "#_bang_element(name_sym, op, *args, &block)" do
    it "should return nil if no element found" do
      result = batman_chain.batman.villains.catwoman!
      result.should be_a ConfigLibrary::NullResult
      result.should be_nil
      result.inspect.should match(/ok for .batman.villains, nil on .catwoman, no callers/)
    end

    it "should return the value if a non-hash element is found" do
      batman_chain.batman.villains.riddler!.should == "Edward E Nigma"
    end

    it "should return a hash if the requested element is a hash" do
      batman_chain.batman.villains!.should be_a Hash
    end
  end

  describe "#_assign_element(name_sym, op, *args, &block)" do
    it "should call the library's _assign_element method passing keychain and original arguments'" do
      batman_chain.library.should_receive(:_deep_assign).with(%w(batman villains catwoman),["Selina Kyle"])
      batman_chain.batman.villains.catwoman = "Selina Kyle"
    end
  end
end
