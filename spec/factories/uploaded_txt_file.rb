FactoryBot.define do
  factory :uploaded_txt_file, class: Hyrax::UploadedFile do
    initialize_with do
      base = File.join(IiifPrint::GEM_PATH, 'spec', 'fixtures', 'files')
      file_path = File.join(base, 'ndnp-sample1-txt.txt')
      new(file: File.open(file_path), user: create(:user))
    end
  end
end
