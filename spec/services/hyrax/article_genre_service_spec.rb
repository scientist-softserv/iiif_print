require 'spec_helper'

RSpec.describe Hyrax::ArticleGenreService do
  let(:service) { described_class.new }

  describe "#select_active_options" do
    it "returns active terms" do
      active_term = ["Advertisement", "http://id.loc.gov/vocabulary/graphicMaterials/tgm000098"]
      expect(service.select_active_options).to include(active_term)
    end
  end
end
