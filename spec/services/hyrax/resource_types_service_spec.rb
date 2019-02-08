require 'spec_helper'

RSpec.describe Hyrax::ResourceTypesService do
  describe "injected newspaper options" do
    subject { described_class }

    it "includes newspaper and microfilm" do
      expect(subject.label("Microfilm")).to be_truthy
      expect(subject.label("Newspaper")).to be_truthy
    end
  end
end
