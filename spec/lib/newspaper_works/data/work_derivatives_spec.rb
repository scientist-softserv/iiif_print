# encoding: UTF-8

require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Data::WorkDerivatives do
  include_context "shared setup"

  let(:bare_work) do
    work = NewspaperPage.new
    work.title = ['Another one']
    work.save!
    work
  end

  let(:work) do
    # sample work comes from shared setup, but we need derivative, save...
    mk_txt_derivative(sample_work)
    sample_work.save!(validate: false)
    sample_work
  end

  let(:adapter) { described_class.new(work) }

  let(:txt1) do
    file = Tempfile.new(['txt1', '.txt'])
    file.write('hello')
    file.flush
    file
  end

  let(:txt2) do
    file = Tempfile.new('txt2.txt')
    file.write('bye')
    file.flush
    file
  end

  let(:encoded_text) do
    file = Tempfile.new('txt_encoded.txt', encoding: 'UTF-8')
    file.write('Gorgonzola Dolce® — on sale for £12.50/kg')
    file.flush
    file
  end

  describe "enumerates available derivatives like hash" do
    it "includes expected derivative path for work" do
      expect(adapter.keys).to include 'txt'
    end

    it "can be introspected for quantity of derivatives" do
      # `size` method without argument is count of derivatives,
      #   functions equivalently to adapter.keys.size
      expect(adapter.size).to eq adapter.keys.size
    end

    it "enumerates expected derivative extension for work" do
      ext_found = adapter.keys
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set" do
      file_set = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.new(file_set)
      ext_found = adapter.keys
      expect(ext_found).to include 'txt'
    end

    it "enumerates expected derivative extension for file set id" do
      file_set = work.members.select { |m| m.class == FileSet }[0]
      adapter = described_class.new(file_set.id)
      ext_found = adapter.keys
      expect(ext_found).to include 'txt'
    end
  end

  describe "loads derivatives for a work" do
    it "Loads text derivative path" do
      expect(File.exist?(adapter.path('txt'))).to be true
      expect(adapter.exist?('txt')).to be true
    end

    it "Loads text derivative data" do
      expect(adapter.data('txt')).to include 'mythical'
    end

    it "Handles character encoding on read" do
      # replace fixture text derivative for work with encoded text
      adapter.attach(encoded_text.path, 'txt')
      data = adapter.data('txt')
      expect(data).to include '—' # em-dash
      expect(data).to include '£' # gb-pound sign
      expect(data.encoding.to_s).to eq 'UTF-8'
    end

    it "Loads thumbnail derivative data" do
      mk_thumbnail_derivative(work)
      # get size by loading data
      expect(adapter.data('thumbnail').bytes.size).to eq 16_743
      # get size by File.size via .size method
      expect(adapter.size('thumbnail')).to eq 16_743
    end

    it "Can access jp2 derivative" do
      mk_jp2_derivative(work)
      expect(File.exist?(adapter.path('jp2'))).to be true
      expect(adapter.exist?('jp2')).to be true
    end
  end

  describe "create, update, delete derivatives" do
    it "will queue derivative file assignment" do
      adapter = described_class.new(bare_work)
      adapter.assign(example_gray_jp2)
      expect(adapter.assigned).to include example_gray_jp2
    end

    it "will remove file assignment from queue" do
      adapter = described_class.new(bare_work)
      expect(adapter.state).to eq 'empty'
      adapter.assign(example_gray_jp2)
      expect(adapter.assigned).to include example_gray_jp2
      expect(adapter.state).to eq 'dirty'
      adapter.unassign(example_gray_jp2)
      expect(adapter.assigned).not_to include example_gray_jp2
      expect(adapter.state).to eq 'empty'
    end

    it "will queue a deletion" do
      # Given a work with a derivative (txt) already assigned
      expect(adapter.state).to eq 'saved'
      # unassigning path...
      adapter.unassign('txt')
      # will lead to queued unassignment (intent to delete)...
      expect(adapter.unassigned).to include 'txt'
      # and a 'dirty' adapter state (unflushed changes):
      expect(adapter.state).to eq 'dirty'
    end

    it "will flush a removal and addition on commit!" do
      # Given a work with a derivative (txt) already assigned
      expect(adapter.keys).to include 'txt'
      expect(adapter.keys).not_to include 'jp2'
      # unassigning path...
      adapter.unassign('txt')
      # and assigning another attachment:
      adapter.assign(example_gray_jp2)
      # ...committing these will flush the changes (synchronously):
      adapter.commit!
      expect(adapter.keys).not_to include 'txt'
      expect(adapter.keys).to include 'jp2'
      expect(adapter.size('jp2')).to eq 27_703
    end

    it "can attach derivative from file" do
      expect(adapter.keys).not_to include 'jp2'
      adapter.attach(example_gray_jp2, 'jp2')
      expect(adapter.exist?('jp2')).to be true
      expect(adapter.path('jp2')).not_to be nil
      expect(File.size(adapter.path('jp2'))).to eq File.size(example_gray_jp2)
      expect(adapter.keys).to include 'jp2'
      d_path = path_factory.derivative_path_for_reference(adapter.fileset_id, 'jp2')
      expect(adapter.values).to include d_path
    end

    it "can replace aderivative with new attachment" do
      adapter.attach(txt1.path, 'txt')
      expect(adapter.data('txt')).to eq 'hello'
      adapter.attach(txt2.path, 'txt')
      expect(adapter.data('txt')).to eq 'bye'
    end

    it "can delete an attached derivative" do
      adapter.attach(txt1.path, 'txt')
      expect(adapter.keys).to include 'txt'
      expect(adapter.data('txt')).to eq 'hello'
      adapter.delete('txt')
      expect(adapter.path('txt')).to be nil
      expect(adapter.keys).not_to include 'txt'
    end

    it "persists log of attachment to RDBMS" do
      adapter.assign(txt1.path)
      result = NewspaperWorks::DerivativeAttachment.find_by(
        fileset_id: adapter.fileset.id,
        path: txt1.path,
        destination_name: 'txt'
      )
      expect(result).not_to be_nil
    end

    it "persists a log of path relation to primary file" do
      # this is an integration test by practical necessity, with
      #   WorkFiles adapting a bare work with no fileset.
      work_files = NewspaperWorks::Data::WorkFiles.of(bare_work)
      work_files.assign(example_gray_jp2)
      adapter = work_files.derivatives
      adapter.assign(txt1.path)
      result = NewspaperWorks::IngestFileRelation.find_by(
        derivative_path: txt1.path,
        file_path: example_gray_jp2
      )
      expect(result).not_to be_nil
    end

    # rubocop:disable RSpec/ExampleLength
    it "commits queued derivatives" do
      NewspaperWorks::IngestFileRelation.where(file_path: example_gray_jp2).delete_all
      work_files = NewspaperWorks::Data::WorkFiles.of(bare_work)
      work_files.assign(example_gray_jp2)
      adapter = work_files.derivatives
      adapter.assign(txt1.path)
      expect(File.exist?(txt1.path)).to be true
      expect(adapter.keys.size).to eq 0
      # we need a fileset, saved with import_url, attached to work:
      fileset = valid_file_set
      fileset.import_url = 'file://' + example_gray_jp2
      fileset.save!
      bare_work.members.push(fileset)
      bare_work.save!
      fileset.reload
      expect(fileset.member_of[0].id).to eq bare_work.id
      # with a new adapter instance...
      adapter2 = described_class.of(bare_work)
      # call .commit_queued! with our fileset...
      expect(File.exist?(txt1.path)).to be true
      adapter2.commit_queued!(fileset)
      # ...which should result in saved, reloaded derivative...
      expect(adapter2.keys.size).to eq 1
      expect(File.size(adapter2.values[0])).to eq File.size(txt1.path)
      # ...also found via Hyrax::DerviativePath:
      found = Hyrax::DerivativePath.derivatives_for_reference(fileset.id)
      expect(found.size).to eq 1
      expect(File.size(found[0])).to eq File.size(txt1.path)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
