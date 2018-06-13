require 'spec_helper'
require 'model_shared'

RSpec.describe Hyrax::NewspaperArticleForm do
  let(:work) { NewspaperArticle.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe "#required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title, :resource_type, :genre, :language, :held_by] }
  end

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq [:title, :resource_type, :genre, :language, :held_by] }
  end

  describe "#secondary_terms" do
    subject { form.secondary_terms }

    it do
      is_expected.to eq [:creator, :contributor, :description, :license,
                         :rights_statement, :publisher, :subject, :identifier,
                         :place_of_publication, :issn, :lccn, :oclcnum,
                         :alternative_title, :author, :photographer,
                         :publication_date, :volume, :edition, :issue_number,
                         :geographic_coverage, :extent, :page_number,
                         :section]
    end
  end
end
