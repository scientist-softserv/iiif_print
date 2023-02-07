require 'fileutils'
require 'spec_helper'

RSpec.describe IiifPrint::PluggableDerivativeService do
  let(:persisted_file_set) do
    fs = FileSet.new
    work.title = ['This is a page!']
    work.members.push(fs)
    fs.instance_variable_set(:@mime_type, 'image/tiff')
    fs.save!(validate: false)
    work.save!(validate: false)
    fs
  end

  let(:fixture_path) do
    File.join(
      IiifPrint::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  describe "service registration" do
    # integration test with Hyrax, verify services is registered

    it "is registered with Hyrax" do
      expect(Hyrax::DerivativeService.services).to include described_class
    end

    it "is the first valid service found" do
      found = Hyrax::DerivativeService.for(FileSet.new)
      expect(found).to be_a described_class
    end
  end

  context "when the FileSet's parent is not IiifPrint configured" do
    before do
      allow(persisted_file_set).to receive(:in_works).and_return([work])
    end

    let(:work) { MyWork.new }

    describe "#plugins" do
      it "uses the default derivatives service" do
        file_set = double(FileSet, parent: MyWork.new)
        service = described_class.new(file_set)
        expect(service.plugins).to eq [Hyrax::FileSetDerivativesService]
      end
    end
  end

  context "when the FileSet's parent is IiifPrint configured" do
    describe "calls the configured derivative plugins" do
      before do
        allow(persisted_file_set).to receive(:in_works).and_return([work])
        allow_any_instance_of(Hyrax::FileSetDerivativesService).to receive(:send)
      end

      let(:work) { MyIiifConfiguredWork.new }

      it "calls each plugin on create" do
        plugins = [FakeDerivativeService]
        create_calls = FakeDerivativeService.create_called
        service = described_class.new(persisted_file_set, plugins: plugins)
        service.create_derivatives('not_a_real_filename')
        expect(FakeDerivativeService.create_called).to eq create_calls + plugins.size
      end

      def touch_fake_derivative_file(file_set, ext)
        path = Hyrax::DerivativePath.derivative_path_for_reference(file_set, ext)
        FileUtils.mkdir_p(File.join(path.split('/')[0..-2]))
        FileUtils.touch(path)
      end

      it "does not re-create existing derivative" do
        create_calls = FakeDerivativeService.create_called
        service = described_class.new(persisted_file_set)
        expect(persisted_file_set.id).not_to be_nil
        # Fake is configured to have 'txt' destination_path, let's create a
        #   destination file in Hyrax's opinionated plate for dest. name.
        touch_fake_derivative_file(persisted_file_set, 'txt')
        service.create_derivatives('/nonsense/source/path/ignored')
        # create calls logged by fake should not increment,
        #   as PluggableDerivativeService should have skipped calling
        #   plugin's create_derivatives method w/ presence of existing derivative
        expect(FakeDerivativeService.create_called).to eq create_calls
      end

      it "calls each plugin on cleanup" do
        expect(FakeDerivativeService.cleanup_called).to eq 0
        plugins = [FakeDerivativeService]
        service = described_class.new(persisted_file_set, plugins: plugins)
        service.cleanup_derivatives
        expect(FakeDerivativeService.cleanup_called).to eq plugins.size
      end
    end

    context "integration tests for plugins" do
      before do
        allow(persisted_file_set).to receive(:in_works).and_return([work])
      end

      let(:work) { MyIiifConfiguredWorkWithAllDerivativeServices.new }

      describe "calls all derivative plugins" do
        def source_image(name)
          File.join(fixture_path, name)
        end

        def derivatives_for(file_set)
          Hyrax::DerivativePath.derivatives_for_reference(file_set)
        end

        def expected_plugins
          [
            Hyrax::FileSetDerivativesService,
            IiifPrint::JP2DerivativeService,
            IiifPrint::PDFDerivativeService,
            IiifPrint::TextExtractionDerivativeService,
            IiifPrint::TIFFDerivativeService
          ]
        end

        # The expected set of Plugins that will run for file set
        it "has expected valid plugins configured" do
          plugins = described_class.new(persisted_file_set).plugins
          fs = persisted_file_set
          services = plugins.map { |plugin| plugin.new(fs) }.select(&:valid?)
          expect(services.length).to eq 5
          used_plugins = services.map(&:class)
          expected_plugins.each do |plugin|
            expect(used_plugins).to include plugin
          end
        end

        it "creates expected derivatives from TIFF source" do
          svc = described_class.new(persisted_file_set)
          svc.create_derivatives(source_image('4.1.07.tiff'))
          made = derivatives_for(persisted_file_set)
          made.each { |path| expect(File.exist?(path)) }
          extensions = made.map { |path| path.split('.')[-1] }
          expect(extensions).to include 'pdf'
          expect(extensions).to include 'jp2'
          expect(extensions).not_to include 'tiff'
          # Thumbnail, created by Hyrax:
          expect(extensions).to include 'jpeg'
        end
      end

      describe "ingest integration" do
        def log_attachment(file_set)
          # create a log entry for the fileset given destination name 'jp2'
          IiifPrint::DerivativeAttachment.create(
            fileset_id: file_set.id,
            path: '/some/arbitrary/path/to.jp2',
            destination_name: 'jp2'
          )
        end

        def jp2_plugin?(plugins)
          r = plugins.select { |p| p.class == IiifPrint::JP2DerivativeService }
          !r.empty?
        end

        it "will not attempt creating over pre-made derivative" do
          service = described_class.new(persisted_file_set)
          # this should be respected, evaluate by obtaining filtered
          #   services list, which must omit JP2DerivativeService
          plugins = service.services(:create_derivatives)
          # initially has jp2 plugin
          expect(jp2_plugin?(plugins)).to be true
          # blacklist jp2 by effect of log entry of pre-made attachment
          log_attachment(service.file_set)
          # omits, after logging intent of previous attachment:
          plugins = service.services(:create_derivatives)
          expect(jp2_plugin?(plugins)).to be false
        end
      end
    end
  end
end
