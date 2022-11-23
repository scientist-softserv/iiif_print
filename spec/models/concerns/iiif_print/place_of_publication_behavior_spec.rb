require 'spec_helper'

# Core Metadata Spec Tests
RSpec.describe IiifPrint::PlaceOfPublicationBehavior do
  class NewspaperishWork < ActiveFedora::Base
    include ::Hyrax::WorkBehavior
    include IiifPrint::NewspaperCoreMetadata
    include ::Hyrax::BasicMetadata
    include IiifPrint::PlaceOfPublicationBehavior
  end

  let(:work) { NewspaperishWork.new }

  it 'has controlled properties' do
    expect(work.controlled_properties).to eq([:place_of_publication])
  end
end
