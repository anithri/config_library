require "spec_helper"

describe ConfigLibrary::MethodChain do
  subject{ConfigLibrary::MethodChain}
  let(:simple_chain) {subject.new("simple", :batman )}
  let(:simple_library) {ConfigLibrary::Base.new(:lifo,COMMON_BATMAN_HASH)}

  describe "#initialize" do
    it "it should set library and key_chain variables" do
      simple_chain.library.should == "simple"
      simple_chain.key_chain.should == [:batman]
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

      simple_chain.should_receive(:_end_element).and_return(true)
      simple_chain.joker!

      simple_chain.should_receive(:_assign_element).and_return(true)
      simple_chain.joker= nil
    end
  end

  describe "#_plain_element(name_sym, *args)" do
    it "should return nil if no element found" do
      simple_chain.library = simple_library
      simple_chain.villains.catwoman.should be_nil
    end

  end
end
