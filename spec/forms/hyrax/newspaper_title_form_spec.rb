require 'spec_helper'
require 'model_shared'

RSpec.describe Hyrax::NewspaperTitleForm do
  let(:work) { NewspaperTitle.new }
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
                         :alternative_title, :edition_name, :frequency,
                         :preceded_by, :succeeded_by,
                         :publication_date_start, :publication_date_end]
    end
  end
end
