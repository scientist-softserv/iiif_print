require 'spec_helper'

RSpec.describe IiifPrint::Metadata do
  let(:base_url) { "https://my.dev.test" }
  let(:solr_hit) { SolrHit.new(attributes) }
  let(:fields) { IiifPrint.default_fields(fields: metadata_fields) }
  let(:metadata_fields) do
    {
      title: {},
      description: {},
      date_modified: {}
    }
  end

  describe ".build_metadata_for" do
    subject(:manifest_metadata) do
      described_class.build_metadata_for(
        work: solr_hit,
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
          expect(manifest_metadata).to eq [
            { "label" => "Creator",
              "value" =>
                ["<a href='#{base_url}/catalog?f%5Bcreator_sim%5D%5B%5D=McAuthor%2C+Arthur&locale=en'>McAuthor, Arthur</a>"] }
          ]
        end
      end

      context "with an authority option" do
        context "rights statement" do
          let(:metadata_fields) { { rights_statement: { render_as: :rights_statement } } }
          let(:attributes) { { "rights_statement_tesim" => ["http://rightsstatements.org/vocab/InC-OW-EU/1.0/"] } }

          it "renders a link and displays a term" do
            expect(manifest_metadata).to eq [
              { "label" => "Rights statement",
                "value" => ["<a href='http://rightsstatements.org/vocab/InC-OW-EU/1.0/'>In Copyright - EU Orphan Work</a>"] }
            ]
          end
        end

        context "license" do
          let(:metadata_fields) { { license: { render_as: :license } } }
          let(:attributes) { { "license_tesim" => ["https://creativecommons.org/licenses/by-sa/4.0/"] } }

          it "renders a link and displays a term" do
            expect(manifest_metadata).to eq [
              { "label" => "License",
                "value" => [
                  "<a href='https://creativecommons.org/licenses/by-sa/4.0/'>Creative Commons BY-SA Attribution-ShareAlike 4.0 International</a>"
                ] }
            ]
          end
        end
      end

      context "when the work is apart of a collection" do
        let(:metadata_fields) { { collection: {} } }
        let(:collection_attributes) { { "id" => "321cba", "title_tesim" => ["My Cool Collection"] } }
        let(:collection_solr_doc) { SolrDocument.new(collection_attributes) }
        let(:attributes) { { "member_of_collection_ids_ssim" => "321cba" } }

        it "renders a link to the collection" do
          allow(SolrDocument).to receive(:find)
          allow(Hyrax::CollectionMemberService).to receive(:run).and_return([collection_solr_doc])
          expect(manifest_metadata).to eq [
            { "label" => "Collection",
              "value" => ["<a href='#{base_url}/collections/321cba'>My Cool Collection</a>"] }
          ]
        end
      end

      context "when the value has an empty string" do
        let(:attributes) { { "title_tesim" => ["This is a title."], "description_tesim" => [""] } }

        it "does not map the field with an empty string" do
          expect(manifest_metadata.flat_map(&:values)).not_to include([""])
          expect(manifest_metadata).to eq [{ "label" => "Title", "value" => ["This is a title."] }]
        end
      end

      context "when the value is an empty string" do
        let(:attributes) { { "description_tesim" => [""] } }

        it "returns and empty array" do
          expect(manifest_metadata).to eq []
        end
      end
    end

    context "for version 3 of the IIIF spec" do
      let(:version) { 3 }

      context "with a field that has some plain text" do
        let(:attributes) { { "title_tesim" => ["My Awesome Title"] } }

        # NOTE: this assumes the I18n.locale is set as :en
        it "maps the metadata accordingly" do
          expect(manifest_metadata).to eq [{ "label" => { "en" => ["Title"] },
                                             "value" => { "none" => ["My Awesome Title"] } }]
        end
      end

      context "with a field that contains a url string" do
        let(:attributes) { { "description_tesim" => ["A url like https://www.example.com/, cool!"] } }

        it "creates a link for the url string" do
          expect(manifest_metadata).to eq [
            { "label" => { "en" => ["Description"] },
              "value" => { "none" =>
                ["A url like <a href='https://www.example.com/' target='_blank'>https://www.example.com/</a>, cool!"] } }
          ]
        end
      end

      context "with a date" do
        let(:attributes) { { "date_modified_dtsi" => "2011-11-11T11:11:11Z" } }

        it "displays it just the date" do
          expect(manifest_metadata).to eq [{ "label" => { "en" => ["Date modified"] },
                                             "value" => { "none" => ["2011-11-11"] } }]
        end
      end

      context "with a faceted option" do
        let(:metadata_fields) { { creator: { render_as: :faceted } } }
        let(:attributes) { { "creator_tesim" => ["McAuthor, Arthur"] } }

        it "adds a link to the faceted search" do
          expect(manifest_metadata). to eq [
            { "label" => { "en" => ["Creator"] },
              "value" => { "none" =>
                ["<a href='#{base_url}/catalog?f%5Bcreator_sim%5D%5B%5D=McAuthor%2C+Arthur&locale=en'>McAuthor, Arthur</a>"] } }
          ]
        end
      end

      context "with an authority option" do
        context "rights statement" do
          let(:metadata_fields) { { rights_statement: { render_as: :rights_statement } } }
          let(:attributes) { { "rights_statement_tesim" => ["http://rightsstatements.org/vocab/InC-OW-EU/1.0/"] } }

          it "renders a link and displays a term" do
            expect(manifest_metadata).to eq [
              { "label" => { "en" => ["Rights statement"] },
                "value" => { "none" => [
                  "<a href='http://rightsstatements.org/vocab/InC-OW-EU/1.0/'>In Copyright - EU Orphan Work</a>"
                ] } }
            ]
          end
        end

        context "license" do
          let(:metadata_fields) { { license: { render_as: :license } } }
          let(:attributes) { { "license_tesim" => ["https://creativecommons.org/licenses/by-sa/4.0/"] } }

          it "renders a link and displays a term" do
            expect(manifest_metadata).to eq [
              { "label" => { "en" => ["License"] },
                "value" => { "none" => [
                  "<a href='https://creativecommons.org/licenses/by-sa/4.0/'>Creative Commons BY-SA Attribution-ShareAlike 4.0 International</a>"
                ] } }
            ]
          end
        end
      end

      context "when the work is apart of a collection" do
        let(:metadata_fields) { { collection: {} } }
        let(:collection_attributes) { { "id" => "321cba", "title_tesim" => ["My Cool Collection"] } }
        let(:collection_solr_doc) { SolrDocument.new(collection_attributes) }
        let(:attributes) { { "member_of_collection_ids_ssim" => "321cba" } }

        it "renders a link to the collection" do
          allow(SolrDocument).to receive(:find)
          allow(Hyrax::CollectionMemberService).to receive(:run).and_return([collection_solr_doc])
          expect(manifest_metadata).to eq [
            { "label" => { "en" => ["Collection"] },
              "value" => { "none" => ["<a href='#{base_url}/collections/321cba'>My Cool Collection</a>"] } }
          ]
        end
      end

      context "when the value has an empty string" do
        let(:attributes) { { "title_tesim" => ["This is a title."], "description_tesim" => [""] } }

        it "does not map the field with an empty string" do
          expect(manifest_metadata.flat_map(&:values)).not_to include({ "none" => [""] })
          expect(manifest_metadata).to eq [
            { "label" => { "en" => ["Title"] }, "value" => { "none" => ["This is a title."] } }
          ]
        end
      end

      context "when the value is an empty string" do
        let(:attributes) { { "description_tesim" => [""] } }

        it "returns and empty array" do
          expect(manifest_metadata).to eq []
        end
      end
    end
  end
end
