require 'spec_helper'

RSpec.describe IiifPrint::NewspaperCoreFormData do
  before do
    allow(described_class).to receive(:model_class).and_return(NewspaperArticle)
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }
    it { is_expected.to include(place_of_publication_attributes: [:id, :_destroy]) }
  end
end
