require 'spec_helper'

describe ConfigLibrary::NullResult, :focus do
  specify { subject.should be_a NilClass }
  it "returns itself when a method it does not recognize is called on it" do
    subject.test_method.should === subject
  end

  it "returns a null result on #inspect"
end
