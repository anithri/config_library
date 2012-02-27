require 'spec_helper'

describe ConfigLibrary do
  subject{ConfigLibrary}

  describe "loaded namespaces" do
    specify {Module.constants.should include(:ConfigLibrary)}
    specify {subject.constants.should include(:Base)}
    specify {subject.constants.should include(:MethodChain)}
    specify {subject.constants.should include(:Settings)}
    specify {subject.constants.should include(:SearchOrderStrategies)}
    specify {subject.constants.should include(:AssignmentError)}
    specify {subject.constants.should include(:KeyError)}
  end

  describe "#name_parts(sym)" do
    specify {subject.name_parts(:test).should == ["test",nil]}

    specify { subject.name_parts(:test).should == ["test", nil] }
    specify { subject.name_parts(:test_).should == ["test_", nil] }
    specify { subject.name_parts(:test?).should == ["test?", nil] }
    specify { subject.name_parts(:test!).should == ["test", "!"] }
    specify { subject.name_parts(:test=).should == ["test", "="] }
    specify { subject.name_parts(:test_case).should == ["test_case", nil] }
    specify { subject.name_parts(:test_case_).should == ["test_case_", nil] }
    specify { subject.name_parts(:test_case?).should == ["test_case?", nil] }
    specify { subject.name_parts(:test_case!).should == ["test_case", "!"] }
    specify { subject.name_parts(:test_case=).should == ["test_case", "="] }
    specify { subject.name_parts(:$this_is_a_long_test_case).should ==
        ["$this_is_a_long_test_case", nil]}
  end

end
