require 'spec_helper'

describe ConfigLibrary::NullResult do
  it "returns itself when a method it does not recognize is called on it" do
    subject.test_method.should == subject
    subject.first.second.third.fourth.should == subject
  end

  specify{ subject.to_a.should == [] }
  specify{ subject.to_s.should == "" }
  specify{ subject.nil?.should == true }
  specify{ (!subject).should be_true}
  specify{ (!!subject).should be_false}

  describe "displays useful data on #inspect" do
    context "when passed no initial message" do
      context "with no further methods called upon it." do
        specify {subject.inspect.should match(/NullResult.+no callers/)}
      end
      context "with further methods called upon it." do
        specify {subject.first.inspect.should match(/NullResult.| \[:first\]/)}
        specify {subject.first.second.inspect.should match(/NullResult.| \[:first, :second\]/)}
      end
    end
    context "when passed an initial message" do
      subject{ConfigLibrary::NullResult.new("default.value")}
      context "with no further methods called upon it." do
        specify {subject.inspect.should match(/NullResult.+default.value.+no callers/)}
      end
      context "with further methods called upon it." do
        specify {subject.first.inspect.should match(/NullResult.+default.value.| \[:first\]/)}
        specify {subject.first.second.inspect.should match(/NullResult.+default.value.| \[:first, :second\]/)}
      end
    end
  end
end
