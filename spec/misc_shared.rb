RSpec.shared_context "shared setup", shared_context: :metadata do
  let(:fixture_path) do
    path = File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
    whitelist = Hyrax.config.whitelisted_ingest_dirs
    whitelist.push(path) unless whitelist.include?(path)
    path
  end

  # shared date to be invariant across all tests in a run:
  date_static = Hyrax::TimeService.time_in_utc
  let(:static_date) { date_static }

  # path fixtures:
  let(:example_gray_jp2) { File.join(fixture_path, 'ocr_gray.jp2') }
  let(:txt_path) { File.join(fixture_path, 'credits.md') }
  let(:sample_thumbnail) { File.join(fixture_path, 'thumbnail.jpg') }

  # sample data:
  let(:sample_text) { 'even in a mythical Age there must be some enigmas' }

  let(:valid_file_set) do
    file_set = FileSet.new
    file_set.save!(validate: false)
    file_set
  end

  let(:sample_work) do
    work = NewspaperPage.new
    work.title = ['Bombadil']
    work.members.push(valid_file_set)
    work.save!
    work
  end

  # sample objects:
  let(:work_with_file) do
    # we need a work with not just a valid (but empty) fileset, but also
    #   a persisted file, so we use the shared work sample, and expand
    #   on it with actual file data/metadata.
    work = sample_work
    fileset = work.members.select { |m| m.class == FileSet }[0]
    file = Hydra::PCDM::File.create
    fileset.original_file = file
    # Set binary content on file via ActiveFedora content= mutator method
    #   which also makes .size method return valid result for content
    file.content = File.open(txt_path)
    # Set some metdata we would expect to otherwise be set upon an upload
    file.original_name = 'credits.md'
    file.mime_type = 'text/plain'
    file.date_modified = static_date
    file.date_created = static_date
    # saving fileset also saves file content
    fileset.save!
    work
  end

  def path_factory
    Hyrax::DerivativePath
  end

  def work_file_set(work)
    work.members.select { |m| m.class == FileSet }[0]
  end

  def text_path(work)
    path_factory.derivative_path_for_reference(work_file_set(work), 'txt')
  end

  def jp2_path(work)
    path_factory.derivative_path_for_reference(work_file_set(work), 'jp2')
  end

  def thumbnail_path(work)
    path_factory.derivative_path_for_reference(work_file_set(work), 'thumbnail')
  end

  def mkdir_derivative(work, name)
    # make shared path for derivatives to live, Hyrax ususally does this
    #   for thumbnails, and newspaper_works does this in its derivative
    #   service plugins; here we do same.
    fsid = work_file_set(work).id
    path = path_factory.derivative_path_for_reference(fsid, name)
    dir = File.join(path.split('/')[0..-2])
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  end

  def mk_jp2_derivative(work)
    mkdir_derivative(work, 'jp2')
    dst_path = jp2_path(work)
    FileUtils.copy(example_gray_jp2, dst_path)
    expect(File.exist?(dst_path)).to be true
  end

  def mk_txt_derivative(work)
    mkdir_derivative(work, 'txt')
    dst_path = text_path(work)
    File.open(dst_path, 'w') { |f| f.write(sample_text) }
    expect(File.exist?(dst_path)).to be true
  end

  def mk_thumbnail_derivative(work)
    mkdir_derivative(work, 'thumbnail')
    dst_path = thumbnail_path(work)
    FileUtils.copy(sample_thumbnail, dst_path)
    expect(File.exist?(dst_path)).to be true
  end
end
