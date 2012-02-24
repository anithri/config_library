require "spec_helper"

describe ConfigLibrary::SearchOrderStrategies do
  subject{ConfigLibrary::SearchOrderStrategies}
  let(:container) { [:first, :second]}
  describe "#manual(container, new_value)" do
    it "should not touch the container" do
      subject.manual(container, :woot)
      container.should == [:first, :second]
    end
  end

  describe "#lifo(container, new_value)" do
    it "should add to the start of the container" do
      subject.lifo(container, :woot)
      container.should == [:woot, :first, :second]
    end
  end

  describe "#fifo(container, new_value)" do
    it "should add to the end of the container" do
      subject.fifo(container, :woot)
      container.should == [:first, :second, :woot]
    end
  end

end