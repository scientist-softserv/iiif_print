require 'spec_helper'

RSpec.describe IiifPrint::Configuration do
  let(:config) { described_class.new }

  describe '#ancestory_identifier_function' do
    subject(:function) { config.ancestory_identifier_function }
    it "is expected to be a lambda with an arity of one" do
      expect(function.arity).to eq(1)
    end

    it "is configurable" do
      expect do
        config.ancestory_identifier_function = ->(w) { w.object_id }
      end.to change { config.ancestory_identifier_function.object_id }
    end
  end

  describe '#child_title_generator_function' do
    subject(:function) { config.child_title_generator_function }

    it "is expected to be a lambda with keyword args" do
      expect(function.parameters).to eq([[:keyreq, :file_path],
                                         [:keyreq, :parent_work],
                                         [:keyreq, :page_number],
                                         [:keyreq, :page_padding]])
    end

    it 'works as originally designed' do
      work = double(title: ["My Title"], id: '1234')
      expect(function.call(
               file_path: __FILE__,
               parent_work: work,
               page_number: 23,
               page_padding: 5
             )).to eq("1234 - configuration_spec.rb Page 00024")
    end

    it "is configurable" do
      expect do
        config.child_title_generator_function = ->(**kwargs) { kwargs }
      end.to change { config.child_title_generator_function.object_id }
    end
  end

  describe "#metadata_fields" do
    subject { config.metadata_fields }

    it { is_expected.to be_a Hash }
    it "allows for an override" do
      original = config.metadata_fields
      config.metadata_fields = { title: {} }
      expect(config.metadata_fields).not_to eq original
    end
  end

  describe "#handle_after_create_fileset" do
    let(:file_set) { double(FileSet) }
    let(:user) { double(User) }
    subject(:called_function) { config.handle_after_create_fileset(file_set, user) }

    context "without configuration" do
      it "calls IiifPrint::Data.handle_after_create_fileset" do
        expect(IiifPrint::Data).to receive(:handle_after_create_fileset).with(file_set, user)

        called_function
      end
    end

    context "with configuration" do
      let(:config_func) { ->(_file_set, _user) { :yup } }

      it "calls the given configured lambda" do
        config.after_create_fileset_handler = config_func
        expect(IiifPrint::Data).not_to receive(:handle_after_create_fileset)
        expect(config_func).to receive(:call).with(file_set, user)
        called_function
      end
    end
  end

  describe '#additional_tessearct_options' do
    context "by default" do
      subject { config.additional_tessearct_options }
      it { is_expected.not_to be_present }
    end

    it "can be configured" do
      expect do
        config.additional_tessearct_options = "-l esperanto"
      end.to change(config, :additional_tessearct_options)
        .from("")
        .to("-l esperanto")
    end
  end

  describe '#default_iiif_manifest_version' do
    subject { config.default_iiif_manifest_version }

    context 'default' do
      it { is_expected.to eq 2 }
    end

    context 'when set to empty' do
      before { config.default_iiif_manifest_version = '' }
      it { is_expected.to eq 2 }
    end

    it 'can be set' do
      expect { config.default_iiif_manifest_version = 3 }
        .to change(config, :default_iiif_manifest_version)
        .from(2)
        .to(3)
    end
  end
end
