require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::Data::WorkFiles do
  include_context "shared setup"

  let(:work) { work_with_file }
  let(:tiff_path) { File.join(fixture_path, 'ocr_gray.tiff') }
  let(:tiff_uri) { 'file://' + File.expand_path(tiff_path) }

  describe "adapter composition" do
    it "adapts work" do
      adapter = described_class.new(work)
      expect(adapter.work).to be work
    end

    it "adapts work with 'of' alt constructor" do
      adapter = described_class.of(work)
      expect(adapter.work).to be work
    end
  end

  describe "path assignment queueing" do
    it "queues assigned file path" do
      adapter = described_class.of(work)
      expect(adapter.assigned).to be_empty
      # assign a valid source path
      adapter.assign(tiff_path)
      expect(adapter.assigned).to include tiff_path
    end

    it "will fail to assign file in non registered dir" do
      adapter = described_class.new(work)
      # need a non-registered file that exists:
      bad_path = File.expand_path("../../spec_helper.rb", fixture_path)
      expect { adapter.assign(bad_path) }.to raise_error(SecurityError)
    end

    it "queues a file:/// URI" do
      adapter = described_class.of(work)
      expect(adapter.assigned).to be_empty
      adapter.assign(tiff_uri)
      expect(adapter.assigned).to include tiff_uri
    end

    it "queues a Pathname, normalized to string" do
      adapter = described_class.of(work)
      expect(adapter.assigned).to be_empty
      adapter.assign(Pathname.new(tiff_path))
      expect(adapter.assigned).to include tiff_path
    end

    it "unqueues a queued path" do
      adapter = described_class.of(work)
      adapter.assign(tiff_path)
      expect(adapter.assigned).to include tiff_path
      adapter.unassign(tiff_path)
      expect(adapter.assigned).to be_empty
    end
  end

  describe "hash/mapping-like file enumeration" do
    it "has expected WorkFile in values for work" do
      adapter = described_class.of(work)
      values = adapter.values
      expect(values).to be_an Array
      expect(values.size).to eq 1
      expect(values[0]).to be_an IiifPrint::Data::WorkFile
      expect(values[0].parent).to be adapter
      first_fileset = work.members.detect { |m| m.is_a?(FileSet) }
      expect(values[0].fileset).to eq first_fileset
      expect(values[0].unwrapped).to be_a Hydra::PCDM::File
    end

    it "has expected fileset keys for work" do
      adapter = described_class.of(work)
      keys = adapter.keys
      expect(keys).to be_an Array
      expect(keys[0]).to be_a String
      first_fileset = work.members.detect { |m| m.is_a?(FileSet) }
      expect(keys[0]).to eq first_fileset.id
    end

    it "has expected entries for work" do
      adapter = described_class.of(work)
      entries = adapter.entries
      expect(entries).to be_an Array
      expect(entries[0]).to be_an Array
      expect(entries[0].size).to eq 2
      expect(entries[0][0]).to eq adapter.keys[0]
      expect(entries[0][1]).to eq adapter.values[0]
    end

    it "gets work file by fileset id" do
      adapter = described_class.of(work)
      first_fileset = work.members.detect { |m| m.is_a?(FileSet) }
      fsid = adapter.keys[0]
      expect(fsid).to eq first_fileset.id
      work_file = adapter.get(fsid)
      expect(work_file.unwrapped).to eq first_fileset.original_file
      work_file = adapter[fsid]
      expect(work_file.unwrapped).to eq first_fileset.original_file
    end

    it "gets work file by work-local filename" do
      adapter = described_class.of(work)
      first_fileset = work.members.detect { |m| m.is_a?(FileSet) }
      name = first_fileset.original_file.original_name
      work_file = adapter.get(name)
      expect(work_file).to eq adapter.get(first_fileset.id)
    end

    it "verifies inclusion of fileset id key" do
      adapter = described_class.of(work)
      fsid = adapter.keys[0]
      expect(adapter.include?(fsid)).to be true
    end
  end

  describe "assignment state" do
    it "has empty state for work with no files" do
      bare_work = MyWork.new
      bare_work.title = ['No files to see here']
      bare_work.save!
      adapter = described_class.of(bare_work)
      expect(adapter.keys.empty?).to be true
      expect(adapter.state).to eq 'empty'
    end

    it "has 'dirty' state when files assigned" do
      adapter = described_class.of(work)
      expect(adapter.state).to eq 'saved'
      adapter.assign(tiff_path)
      # changes to dirty
      expect(adapter.state).to eq 'dirty'
      # unassign path again to empty assigned queue:
      adapter.unassign(tiff_path)
      # no we are back to 'saved' since no changes are queued now:
      expect(adapter.state).to eq 'saved'
    end
  end

  describe "commits changes" do
    # We need to register these jobs to run now, at minimum:
    do_now_jobs = [IngestLocalFileJob, IngestJob, InheritPermissionsJob]
    # These we skip: [CharacterizeJob, CreateDerivativesJob]
    #   -- skipping these saves 10-15 seconds on attachment example

    permission_methods = [
      :edit_users,
      :read_users,
      :discover_users,
      :edit_groups,
      :read_groups,
      :discover_groups
    ]

    let(:bare_work) do
      bare_work = MyWork.new
      bare_work.title = ['No files to see here']
      bare_work.save!
      bare_work
    end

    it "commits unassign (file deletions)" do
      adapter = described_class.of(work)
      expect(adapter.keys.size).to eq 1
      adapter.unassign(adapter.keys[0])
      adapter.commit!
      expect(adapter.keys.size).to eq 0
      expect(work.members.count { |m| m.is_a? FileSet }).to eq 0
    end

    context "when it is a new work" do
      it "commit for assignment invokes actor stack" do
        work = MyWork.new(title: ['Just a new work'])
        adapter = described_class.of(work)
        adapter.assign(tiff_path)
        allow(Hyrax::CurationConcern.actor).to receive(:create).and_return(true)
        expect(Hyrax::CurationConcern.actor).to receive(:create)
        expect(adapter.commit!).to be true
      end
    end

    context "when the work already exists" do
      it "commit for assignment invokes actor stack" do
        work = bare_work
        adapter = described_class.of(work)
        adapter.assign(tiff_path)
        allow(Hyrax::CurationConcern.actor).to receive(:update).and_return(true)
        expect(Hyrax::CurationConcern.actor).to receive(:update)
        expect(adapter.commit!).to be true
      end
    end

    xit "commits successful file attachment", perform_enqueued: do_now_jobs do
      work = bare_work
      adapter = described_class.of(work)
      adapter.assign(tiff_path)
      adapter.commit!
      # registered jobs (do_now_jobs) performed as effect of commit!
      #   are configured to effectively run inline. Reloading work
      #   should refresh the work.members, and by consequence adapter.keys
      work.reload
      expect(adapter.keys.size).to eq 1
      expect(work.members.count { |m| m.is_a? FileSet }).to eq 1
      expect(adapter.names).to include 'ocr_gray.tiff'
    end

    xit "copies work perimssions to fileset", perform_enqueued: do_now_jobs do
      adapter = described_class.of(bare_work)
      adapter.assign(tiff_path)
      adapter.commit!
      bare_work.reload
      fileset = bare_work.members.detect { |m| m.is_a?(FileSet) }
      permission_methods.each do |m|
        expect(fileset.send(m)).to match_array bare_work.send(m)
      end
      expect(fileset.visibility).to eq bare_work.visibility
    end
  end

  describe "derivative access" do
    it "gets derivatives for first fileset" do
      fileset = work.members.detect { |m| m.is_a?(FileSet) }
      adapter = described_class.of(work)
      # adapts same context(s):
      expect(adapter.derivatives.fileset.id).to eq fileset.id
      expect(adapter.derivatives.work).to be work
      expect(adapter.derivatives.class).to eq \
        IiifPrint::Data::WorkDerivatives
      # transitive parent/child relationship, can traverse to adapter from
      # derivatives:
      expect(adapter.derivatives.parent.parent).to be adapter
    end
  end
end
