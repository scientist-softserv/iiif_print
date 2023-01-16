require 'spec_helper'

RSpec.describe IiifPrint::Metadata do
  let(:base_url) { "https://my.dev.test" }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:fields) do
    metadata_fields.map do |field|
      SampleField.new(
        name: field.first,
        label: Hyrax::Renderers::AttributeRenderer.new(field, nil).label,
        options: field.last
      )
    end
  end
  let(:metadata_fields) do
    {
      title: {},
      description: {},
      date_modified: {}
    }
  end

  SampleField = Struct.new(:name, :label, :options, keyword_init: true)

  describe ".build_metadata_for" do
    subject(:manifest_metadata) do
      described_class.build_metadata_for(
        model: solr_document,
        version: version,
        fields: fields,
        current_ability: double(Ability),
        base_url: base_url
      )
    end

    context "for version 2 of the IIIF spec" do
      let(:version) { 2 }

      context "with a field that has some plain text" do
        let(:attributes) { { "title_tesim" => ["My Awesome Title"] } }

        it "maps the metadata accordingly" do
          expect(manifest_metadata).to eq [
            { "label" => "Title", "value" => ["My Awesome Title"] }
          ]
        end
      end

      context "with a field that contains a url string" do
        let(:attributes) { { "description_tesim" => ["A url like https://www.example.com/, cool!"] } }

        it "creates a link for the url string" do
          expect(manifest_metadata).to eq [
            { "label" => "Description",
               "value" =>
                [
                  "A url like <a href='https://www.example.com/' target='_blank'>https://www.example.com/</a>, cool!"
                ] }
          ]
        end
      end

      context "with a date" do
        let(:attributes) { { "date_modified_dtsi" => "2011-11-11T11:11:11Z" } }

        it "displays it just the date" do
          expect(manifest_metadata).to eq [{ "label" => "Date modified", "value" => ["2011-11-11"] }]
        end
      end

      context "with a faceted option" do
        let(:metadata_fields) { { creator: { render_as: :faceted } } }
        let(:attributes) { { "creator_tesim" => ["McAuthor, Arthur"] } }

        it "adds a link to the faceted search" do
          expect(manifest_metadata). to eq [
            { "label" => "Creator",
              "value" =>
                ["<a href='#{base_url}/catalog?f%5Bcreator_sim%5D%5B%5D=McAuthor%2C+Arthur&locale=en'>McAuthor, Arthur</a>"] }
          ]
        end
      end

      context "when the work is apart of a collection" do
        let(:metadata_fields) { { collection: {} } }
        let(:collection_attributes) { { "id" => "321cba", "title_tesim" => ["My Cool Collection"] } }
        let(:collection_solr_doc) { SolrDocument.new(collection_attributes) }
        let(:attributes) { { "member_of_collection_ids_ssim" => "321cba" } }

        it "renders a link to the collection" do
          allow(Hyrax::CollectionMemberService).to receive(:run).and_return([collection_solr_doc])
          expect(manifest_metadata).to eq [
            { "label" => "Collection",
              "value" => ["<a href='#{base_url}/collections/321cba'>My Cool Collection</a>"] }
          ]
        end
      end
    end

    context "for version 3 of the IIIF spec", skip: "version 3 metadata not implemented yet" do
      let(:version) { 3 }

      it "maps the metadata accordingly" do
        # NOTE: this assumes the I18n.locale is set as :en
        expect(manifest_metadata).to eq [
          { "label" => { "en" => ["Title"] }, "value" => { "none" => ["My Awesome Title"] } },
          { "label" => { "en" => ["Description"] },
            "value" => { "none" => ["This is and awesome description"] } },
          { "label" => { "en" => ["Date modified"] }, "value" => { "none" => ["2011-11-11"] } },
          { "label" => { "en" => ["Creator"] }, "value" => { "none" => ["McAuthor, Arthur"] } }
        ]
      end
    end
  end
end
