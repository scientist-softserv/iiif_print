require 'spec_helper'

RSpec.describe IiifPrint::Metadata do
  let(:solr_document) { SolrDocument.new(attributes) }

  SampleField = Struct.new(:name, :label, :options, keyword_init: true)

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

  describe ".manifest_for" do
    subject(:manifest_metadata) do
      described_class.manifest_for(
        model: solr_document,
        version: version,
        fields: fields
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
                ["<a href='/catalog?f%5Bcreator_sim%5D%5B%5D=McAuthor%2C+Arthur&locale=en'>McAuthor, Arthur</a>"] }
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
