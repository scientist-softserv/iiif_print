require 'spec_helper'

RSpec.describe IiifPrint do
  describe '.skip_splitting_pdf_files_that_end_with_these_texts' do
    subject { described_class }
    it { is_expected.to respond_to :skip_splitting_pdf_files_that_end_with_these_texts }
  end

  describe ".manifest_metadata_for" do
    let(:attributes) do
      { "id" => "abc123",
        "title_tesim" => ['My Awesome Title'] }
    end
    let(:solr_document) { SolrDocument.new(attributes) }
    let(:base_url) { "https://my.dev.test" }

    subject(:manifest_metadata) do
      described_class.manifest_metadata_for(work: solr_document, current_ability: double(Ability), base_url: base_url)
    end
    it { is_expected.not_to be_falsey }
    it "does not contain any nil values" do
      expect(subject).not_to include(nil)
    end
  end

  describe ".model_configuration" do
    context "default configuration" do
      let(:model) do
        Class.new do
          include IiifPrint.model_configuration(pdf_split_child_model: Class.new)
        end
      end

      subject(:record) { model.new }

      it { is_expected.to be_iiif_print_config }

      it "has a #pdf_splitter_job" do
        expect(record.iiif_print_config.pdf_splitter_job).to be(IiifPrint::Jobs::ChildWorksFromPdfJob)
      end

      it "has a #pdf_splitter_service" do
        expect(record.iiif_print_config.pdf_splitter_service).to be(IiifPrint::SplitPdfs::PagesToJpgsSplitter)
      end

      it "has #derivative_service_plugins" do
        expect(record.iiif_print_config.derivative_service_plugins).to eq(
          [IiifPrint::TextExtractionDerivativeService]
        )
      end
    end
  end

  describe ".fields_for_allinson_flex" do
    subject { described_class.fields_for_allinson_flex(fields: fields, sort_order: sort_order) }
    let(:sort_order) { [] }

    context "when the fields include an admin only indexing property" do
      let(:fields) do
        [
          IiifPrint::CollectionFieldShim.new(name: :title, value: "My Title"),
          IiifPrint::CollectionFieldShim.new(name: :creator, value: "Hyrax, Sam", indexing: ["admin_only"])
        ]
      end

      it "does not include the admin only field" do
        # We are mapping from one data structure to another
        expect(subject.map(&:name)).to eq([fields.first.name])
      end
    end

    context "when the fields include duplicate name properties" do
      let(:fields) do
        [
          IiifPrint::CollectionFieldShim.new(name: :title, value: "My Title"),
          IiifPrint::CollectionFieldShim.new(name: :title, value: "My Other Title")
        ]
      end

      it "does not include later duplicates" do
        expect(subject.map(&:label)).to eq([fields.first.value])
      end
    end

    context "when we provide a fields sort order" do
      let(:fields) do
        [
          IiifPrint::CollectionFieldShim.new(name: :title, value: "My Title"),
          IiifPrint::CollectionFieldShim.new(name: :creator, value: "Hyrax, Sam"),
          IiifPrint::CollectionFieldShim.new(name: :date_created, value: "2023-05-02")
        ]
      end
      let(:sort_order) { [:creator, :title] }

      it "returns the fields in the order specified and puts unspecified fields last" do
        expect(subject.map(&:name)).to eq([:creator, :title, :date_created])
      end
    end
  end

  describe ".sort_af_fields!" do
    let(:fields) { [:title, :creator, :date_created].map { |name| IiifPrint::Field.new(name: name) } }
    subject(:sort_af_fields) { described_class.sort_af_fields!(fields, sort_order: sort_order) }

    context "when the sort order is an empty array" do
      let(:sort_order) { [] }

      it "returns the fields in the order they were given" do
        expect(sort_af_fields).to eq(fields)
      end
    end

    context "when the sort order specifies some of the fields" do
      let(:sort_order) { [:date_created, :title] }

      it "returns the fields in the order specified and puts unspecified fields last" do
        expect(sort_af_fields).to eq([:date_created, :title, :creator].map { |name| IiifPrint::Field.new(name: name) })
      end
    end
  end

  describe '.conditionally_submit_split_for' do
    context 'when the file suffix is one that we skip' do
      subject do
        described_class.conditionally_submit_split_for(
          work: double,
          file_set: double,
          locations: ['hello.reader.pdf'],
          skip_these_endings: ['.reader.pdf'],
          user: double
        )
      end

      it { is_expected.to eq(:no_pdfs_for_splitting) }
    end
  end

  describe '.split_for_path_suffix?' do
    context 'with default .skip_splitting_pdf_files_that_end_with_these_texts' do
      subject { described_class.split_for_path_suffix?(path) }
      [
        ["hello.pdf", true],
        ["hello.PDF", true],
        ["hello.reader.pdf", true],
        ["hello.png", false],
        ["hello.pdf.png", false]
      ].each do |given_path, expected_value|
        context "with #{given_path.inspect}" do
          let(:path) { given_path }
          it { is_expected.to eq(expected_value) }
        end
      end
    end

    describe '.use_valkyrie?' do
      context 'with valkyrie' do
        class SomeValkyrieResource < Hyrax::Work; end
        context 'with a valkyrie class' do
          let(:obj) { SomeValkyrieResource }
          it 'returns true' do
            expect(described_class.use_valkyrie?(obj)).to be true
          end
        end

        context 'with a valkyrie instance' do
          let(:obj) { SomeValkyrieResource.new }
          it 'returns true' do
            expect(described_class.use_valkyrie?(obj)).to be true
          end
        end
      end

      context 'with active fedora' do
        class SomeAfWork < ActiveFedora::Base; end
        context 'with an af class' do
          let(:obj) { SomeAfWork }
          it 'returns false' do
            expect(described_class.use_valkyrie?(obj)).to be false
          end
        end

        context 'with an af instance' do
          let(:obj) { SomeAfWork.new }
          it 'returns false' do
            expect(described_class.use_valkyrie?(obj)).to be false
          end
        end
      end
    end

    context 'with customized .skip_splitting_pdf_files_that_end_with_these_texts' do
      subject { described_class.split_for_path_suffix?(path, skip_these_endings: ['.READER.pdf']) }
      [
        ["hello.pdf", true],
        ["hello.PDF", true],
        ["hello.reader.pdf", false],
        ["hello.png", false],
        ["hello.pdf.png", false]
      ].each do |given_path, expected_value|
        context "with #{given_path.inspect}" do
          let(:path) { given_path }
          it { is_expected.to eq(expected_value) }
        end
      end
    end
  end
end
