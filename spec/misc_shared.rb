RSpec.shared_context "shared setup", shared_context: :metadata do
  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  # sample image
  let(:example_gray_jp2) { File.join(fixture_path, 'ocr_gray.jp2') }

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
end
