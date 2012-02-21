require "spec_helper"

describe ConfigLibrary::MethodChain, :focus do
  subject{ConfigLibrary::MethodChain}
  let(:simple_chain) {subject.new("simple", :batman )}

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


      end
    end

  end


  describe "#method_missing(name_sym, *args)" do

  end




end