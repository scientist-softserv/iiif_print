require 'spec_helper'

module NewspaperWorks
  RSpec.describe DerivativeAttachment, type: :model do
    it "requires some columns to be considered complete" do
      model = described_class.create
      # attempt save without required data; expect failure
      expect { model.save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "saves when constructed with all field values" do
      model = described_class.create(
        fileset_id: 'a1b2c3d4e5',
        path: '/path/to/somefile',
        destination_name: 'txt'
      )
      # attempt save without required data; expect failure
      expect { model.save! }.not_to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "saves when all fields completely set" do
      model = described_class.create
      model.fileset_id = 'someid123'
      model.path = '/path/to/somefile'
      model.destination_name = 'txt'
      expect { model.save! }.not_to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "saves when only path, destination_name set" do
      model = described_class.create
      model.fileset_id = nil
      model.path = '/path/to/somefile'
      model.destination_name = 'txt'
      expect { model.save! }.not_to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
