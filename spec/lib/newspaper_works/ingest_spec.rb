require 'spec_helper'

describe NewspaperWorks::Ingest do
  describe "Ingest module methods" do
    it "gets default admin set" do
      admin_set = described_class.find_admin_set
      expect(admin_set).to be_an AdminSet
      expect(admin_set.id).to eq AdminSet::DEFAULT_ID
    end

    # initial expectations of a just-created work without administrative
    #   metadata set yet; AKA the "before" picture
    def expect_initial_work_state(work)
      expect(work.admin_set).to be_nil
      expect(work.depositor).to be_nil
      expect(work.visibility).to eq 'restricted'
      expect(work.date_modified).to be_nil
      expect(work.date_uploaded).to be_nil
      expect(work.resource_type).to be_empty
      expect(work.state).to be_nil
    end

    it "sets default assigned metadata for a work" do
      work = NewspaperTitle.create!(title: ["hello"])
      expect_initial_work_state(work)
      described_class.assign_administrative_metadata(work)
      expect(work.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(work.depositor).to eq User.batch_user.user_key
      expect(work.visibility).to eq 'open'
      expect(work.state).to be_an ActiveTriples::Resource
      expect(work.state.to_uri.to_s).to eq \
        'http://fedora.info/definitions/1/0/access/ObjState#active'
      expect(work.date_uploaded).to be_a DateTime
      expect(work.date_modified).to eq work.date_uploaded
      expect(work.resource_type).to match_array ['Newspapers']
    end
  end
end
