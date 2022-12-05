FactoryBot.define do
  factory :uploaded_pdf_file, class: Hyrax::UploadedFile do
    initialize_with do
      base = File.join(IiifPrint::GEM_PATH, 'spec', 'fixtures', 'files')
      pdf_path = File.join(base, 'minimal-2-page.pdf')
      new(file: File.open(pdf_path), user: create(:user))
    end
  end
end
