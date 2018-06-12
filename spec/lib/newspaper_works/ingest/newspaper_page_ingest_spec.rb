require 'spec_helper'
require 'faraday'

# test NewspaperPageIngest against work
RSpec.describe NewspaperWorks::Ingest::NewspaperPageIngest do
  # define the path to the file we will use for multiple examples
  let(:path) do
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files')
    File.join(fixtures, 'page1.tiff')
  end

  it_behaves_like('ingest adapter IO')

  describe "file import and attachment" do
    it "ingests file data and saves" do
      adapter = build(:newspaper_page_ingest)
      # Rails.application.config.active_job.queue_adapter = :inline
      adapter.ingest(path)
      # Rails.application.config.active_job.queue_adapter = :sidekiq
      file_sets = adapter.work.members.select { |w| w.class == FileSet }
      expect(file_sets[0].title).to contain_exactly 'page1.tiff'
      expect(file_sets.size).to eq 1
      # TODO: re-enable this if we can come to a reliable way to run all
      #   the stuff Hyrax does via AttachFilesToWorkJob inline:
      # files = file_sets[0].files
      # expect(files.size).to eq 1
      # url = files[0].uri.to_s
      # stored_size = Faraday.get(url).body.length
      # expect(stored_size).to eq File.size(path)
    end
  end
end
