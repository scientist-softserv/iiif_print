require 'spec_helper'
require 'model_shared'

RSpec.describe Hyrax::NewspaperIssueForm do
  let(:work) { NewspaperIssue.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe "#required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title, :resource_type, :language, :held_by] }
  end

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq [:title, :resource_type, :language, :held_by] }
  end

  describe "#secondary_terms" do
    subject { form.secondary_terms }

    it do
      is_expected.to eq [:license, :rights_statement, :publisher, :identifier,
                         :place_of_publication, :issn, :lccn, :oclcnum,
                         :alternative_title, :volume, :edition_number,
                         :edition_name, :issue_number, :extent,
                         :publication_date]
    end
  end
end
