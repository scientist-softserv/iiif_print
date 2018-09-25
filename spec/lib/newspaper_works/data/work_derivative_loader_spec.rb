require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkDerivativeLoader do
  include_context "shared setup"

  let(:work) do
    # sample work comes from shared setup, but we need derivative, save...
    mk_txt_derivative(sample_work)
    sample_work.save!(validate: false)
    sample_work
  end

  describe "enumerates available derivatives" do
    it "includes expected derivative path for work" do
      loader = described_class.new(work)
      ext_found = loader.paths.map { |v| v.split('.')[-1] }
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for work" do
      loader = described_class.new(work)
      ext_found = loader.to_a
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set" do
      file_set = work.members.select { |m| m.class == FileSet }[0]
      loader = described_class.new(file_set)
      ext_found = loader.to_a
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set id" do
      file_set = work.members.select { |m| m.class == FileSet }[0]
      loader = described_class.new(file_set.id)
      ext_found = loader.to_a
      expect(ext_found).to include 'txt'
    end
  end

  describe "loads derivatives for a work" do
    it "Loads text derivative path" do
      loader = described_class.new(work)
      expect(File.exist?(loader.path('txt'))).to be true
    end

    it "Loads text derivative data" do
      loader = described_class.new(work)
      expect(loader.data('txt')).to include 'mythical'
    end

    it "Can access jp2 derivative" do
      mk_jp2_derivative(work)
      loader = described_class.new(work)
      expect(File.exist?(loader.path('jp2'))).to be true
    end
  end
end
