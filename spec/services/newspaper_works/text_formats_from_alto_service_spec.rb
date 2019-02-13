require 'nokogiri'
require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::TextFormatsFromALTOService do
  include_context "shared setup"

  let(:valid_file_set) do
    file_set = FileSet.new
    file_set.save!(validate: false)
    file_set
  end

  let(:work) do
    work = NewspaperPage.create(title: ["Hello"])
    work.members << valid_file_set
    work.save!
  end

  let(:minimal_alto) do
    File.join(fixture_path, 'minimal-alto.xml')
  end

  def log_incoming_attachment(fsid)
    NewspaperWorks::DerivativeAttachment.create!(
      fileset_id: fsid,
      path: minimal_alto,
      destination_name: 'xml'
    )
  end

  def derivatives_of(work, fileset)
    NewspaperWorks::Data::WorkDerivatives.of(work, fileset)
  end

  describe "Saves other formats from ALTO" do
    it "saves JSON, text from existing ALTO derivative" do
      derivatives = derivatives_of(work, valid_file_set)
      expect(derivatives.keys.size).to eq 0
      derivatives.attach(minimal_alto, 'xml')
      expect(derivatives.keys.size).to eq 1
      service = described_class.new(valid_file_set)
      service.create_derivatives('/some/random/primary/path/does_not/matter')
      derivatives.load_paths
      expect(derivatives.keys.size).to eq 3
      expect(derivatives.keys).to include 'json', 'txt'
    end

    it "saves JSON, text from incoming ALTO derivative" do
      derivatives = derivatives_of(work, valid_file_set)
      expect(derivatives.keys.size).to eq 0
      log_incoming_attachment(valid_file_set.id)
      service = described_class.new(valid_file_set)
      service.create_derivatives('/some/random/primary/path/does_not/matter')
      # reload keys to check derivatives:
      derivatives.load_paths
      expect(derivatives.keys).to include 'json', 'txt'
    end
  end
end
