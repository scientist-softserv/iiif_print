require 'spec_helper'
require 'model_shared'

RSpec.describe Hyrax::NewspaperPageForm do
  let(:work) { NewspaperPage.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe "#required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title] }
  end

  describe "#primary_terms" do
    subject { form.primary_terms }

    it { is_expected.to eq [:title] }
  end

  describe "#secondary_terms" do
    subject { form.secondary_terms }

    it do
      is_expected.to eq [:identifier, :height, :width, :text_direction,
                         :page_number, :section]
    end
  end
end
