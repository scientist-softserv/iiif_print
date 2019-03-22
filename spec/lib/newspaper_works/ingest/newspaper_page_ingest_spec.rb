require 'spec_helper'
require 'misc_shared'
require 'faraday'

# test NewspaperPageIngest against work
RSpec.describe NewspaperWorks::Ingest::NewspaperPageIngest do
  include_context "shared setup"

  # define the path to the file we will use for multiple examples
  let(:path) do
    File.join(fixture_path, 'page1.tiff')
  end

  it_behaves_like('ingest adapter IO')

  describe "file import and attachment" do
    do_now_jobs = [
      IngestJob,
      IngestLocalFileJob,
      InheritPermissionsJob,
      VisibilityCopyJob
    ]

    permission_methods = [
      :edit_users,
      :read_users,
      :discover_users,
      :edit_groups,
      :read_groups,
      :discover_groups
    ]

    def verify_pcdm_fileset(fileset)
      # Hyrax always sets label (if not title) on fileset:
      expect(fileset.label).to eq 'page1.tiff'
      # reload file set and check on original file
      fileset.reload
      file = fileset.original_file
      expect(file).to be_a Hydra::PCDM::File
    end

    def verify_attached_file(work, path)
      work.reload
      files = NewspaperWorks::Data::WorkFiles.of(work)
      expect(files.keys.size).to eq 1
      expect(File.exist?(files.values[0].path)).to be true
      expect(files.values[0].size).to eq File.size(path)
    end

    it "ingests file data and saves", perform_enqueued: do_now_jobs do
      adapter = build(:newspaper_page_ingest)
      adapter.ingest(path)
      file_sets = adapter.work.members.select { |w| w.class == FileSet }
      expect(file_sets.size).to eq 1
      verify_pcdm_fileset(file_sets[0])
      verify_attached_file(adapter.work, path)
    end

    # For (minimal) page objects constructed in tests, PDF ingest,
    #   permission setting on fileset happens as result of attachment
    #   process (`NewspaperWorks::Data::WorkFiles`), via the
    #   `NewspaperWorks::Data::handle_after_create_fileset` method,
    #   since the CreateWithRemoteFilesActor in Hyrax unfortunately
    #   does not invoke InheritPermissionJob.
    it "copies work permissions to fileset", perform_enqueued: do_now_jobs do
      adapter = build(:newspaper_page_ingest)
      adapter.ingest(path)
      adapter.work.reload
      file_sets = adapter.work.members.select { |w| w.class == FileSet }
      fileset = file_sets[0]
      permission_methods.each do |m|
        expect(fileset.send(m)).to match_array adapter.work.send(m)
      end
      expect(fileset.visibility).to eq adapter.work.visibility
    end
  end
end
