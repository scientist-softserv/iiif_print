# Shared Model
RSpec.shared_examples 'a persistent work type' do
  let(:work) { described_class.new }
  let(:cls) { described_class }

  describe 'class membership' do
    it 'has correct instance type' do
      expect(work).to be_an_instance_of(cls)
    end

    it 'initially has nil id' do
      expect(work.id).to be_nil
    end
  end

  describe 'object persistence' do
    before do
      work.title = ['San Diego Evening Tribune']
      work.save!
    end

    it 'has non-nil id after save' do
      expect(work.id).not_to be_nil
    end

    it 'appears to be persisted in fcrepo' do
      expect(cls.all.map(&:id)).to include(work.id)
    end

    describe 'deletion' do
      it 'deletes via delete' do
        work.delete
        expect(cls.all.map(&:id)).not_to include(work.id)
      end
    end
  end
end

RSpec.shared_examples 'a PCDM file set' do
  let(:work) { described_class.new }
  let(:cls) { described_class }

  it 'looks like a fileset by method introspection' do
    expect(work.file_set?).to be true
  end

  it 'does not look like a work' do
    expect(work.work?).to be false
  end

  it 'still looks like a PCDM object, though' do
    expect(work.pcdm_object?).to be true
  end
end

RSpec.shared_examples 'a work and PCDM object' do
  let(:work) { described_class.new }
  let(:cls) { described_class }

  it 'looks like a work' do
    expect(work.work?).to be true
  end

  it 'also looks like a PCDM object' do
    expect(work.pcdm_object?).to be true
  end

  it 'does not look like a fileset' do
    expect(work.file_set?).to be false
  end
end
