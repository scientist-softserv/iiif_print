# Generated via
#  `rails generate hyrax:work NewspaperContainer`
require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperContainer do
  # rubocop:disable RSpec/InstanceVariable
  before(:all) do
    @fixture = model_fixtures(described_class)
  end

  # shared behaviors
  it_behaves_like('a work and PCDM object')
  it_behaves_like('a persistent work type')

  describe "Metadata properties" do
    it "has expected properties" do
      expect(@fixture).to respond_to(:extent)
      expect(@fixture).to respond_to(:publication_date_start)
      expect(@fixture).to respond_to(:publication_date_end)
    end
  end

  describe "Relationship methods" do
    it "has expected test fixture" do
      expect(@fixture).to be_an_instance_of(described_class)
    end

    it "can get aggregating publication/title" do
      parent = @fixture.publication
      expect(parent).not_to be_nil
      expect(parent).to be_an_instance_of(NewspaperTitle)
      # reciprocity and round-trip
      expect(parent.containers).to include @fixture
    end

    it "can get aggregated pages" do
      contained_pages = @fixture.pages
      expect(contained_pages).to be_an_instance_of(Array)
      expect(contained_pages.length).to be > 0
      contained_pages.each do |e|
        expect(e).to be_an_instance_of(NewspaperPage)
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable

  describe 'publication_date_start' do
    it "is not valid with bad date format" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_start: "06/21/1978")
      expect(nc).not_to be_valid
    end

    it "is valid with proper date format" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_start: "1978-06-21")
      expect(nc).to be_valid
    end

    it "is valid with a year" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_start: "1978")
      expect(nc).to be_valid
    end

    it "is valid with a year and month" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_start: "1978-06")
      expect(nc).to be_valid
    end

    it "is not valid with start date after end date" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_start: "1978-06-01",
                               publication_date_end: "1977-06-01")
      expect(nc).not_to be_valid
    end

    it "is valid with start date before end date" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_start: "1978-06-01",
                               publication_date_end: "1979-06-01")
      expect(nc).to be_valid
    end
  end

  describe 'publication_date_end' do
    it "is not valid with bad date format" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_end: "06/21/1978")
      expect(nc).not_to be_valid
    end

    it "is valid with proper date format" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_end: "1978-06-21")
      expect(nc).to be_valid
    end

    it "is valid with a year" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_end: "1978")
      expect(nc).to be_valid
    end

    it "is valid with a year and month" do
      nc = described_class.new(title: ["Breaking News!"],
                               publication_date_end: "1978-06")
      expect(nc).to be_valid
    end
  end
end
