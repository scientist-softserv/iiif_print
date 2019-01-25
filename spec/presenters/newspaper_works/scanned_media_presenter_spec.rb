RSpec.shared_examples "a scanned media presenter" do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org') }
  let(:user_key) { 'a_user_key' }

  let(:scanned_media_attributes) do
    { "text_direction" => 'left',
      "page_number" => '5',
      "section" => '1' }
  end

  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  it { is_expected.to delegate_method(:text_direction).to(:solr_document) }
  it { is_expected.to delegate_method(:page_number).to(:solr_document) }
  it { is_expected.to delegate_method(:section).to(:solr_document) }
end
