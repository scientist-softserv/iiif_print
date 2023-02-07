require 'spec_helper'

module IiifPrint
  RSpec.describe IngestFileRelation, type: :model do
    def make_test_records
      # two unique values
      described_class.create(
        file_path: '/some/path/to/this',
        derivative_path: '/some/path/to/that'
      )
      described_class.create(
        file_path: '/some/path/to/this',
        derivative_path: '/some/path/to/other_thing'
      )
      # a duplicate will save, presumption is that dupes are filtered on query:
      described_class.create(
        file_path: '/some/path/to/this',
        derivative_path: '/some/path/to/other_thing'
      )
    end

    it "will not save unless record is complete" do
      model = described_class.create
      # attempt save without required data; expect failure
      expect { model.save! }.to raise_exception(ActiveRecord::RecordInvalid)
      model2 = described_class.create
      model2.file_path = '/path/to/sourcefile.tiff'
      expect { model2.save! }.to raise_exception(ActiveRecord::RecordInvalid)
      model3 = described_class.create
      model3.derivative_path = '/path/to/sourcefile.tiff'
      expect { model3.save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "will save sufficiently constructed record" do
      model = described_class.create(
        file_path: '/path/to/this',
        derivative_path: '/path/to/that'
      )
      expect { model.save! }.not_to raise_exception
    end

    it "will save when all fields completely set" do
      model = described_class.create
      model.file_path = '/path/to/sourcefile.tiff'
      model.derivative_path = '/path/to/derived.jp2'
      expect { model.save! }.not_to raise_exception
    end

    it "can query derivative paths for primary file" do
      make_test_records
      result = described_class.derivatives_for_file('/some/path/to/this')
      expect(result).to be_an Array
      expect(result.size).to eq 2
    end
  end
end
