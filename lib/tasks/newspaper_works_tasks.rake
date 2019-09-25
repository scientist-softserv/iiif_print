namespace :newspaper_works do
  def use_application
    ENV['RAILS_ENV'] = Rails.env if ENV['RAILS_ENV'].nil?
    Rails.application.require_environment!
  end

  desc 'Ingest an NDNP batch: "rake newspaper_works:ingest_ndnp -- --path="'
  task :ingest_ndnp do
    use_application
    ingester = NewspaperWorks::Ingest::NDNP::BatchIngester.from_command(
      ARGV,
      'rake newspaper_works:ingest_ndnp --'
    )
    puts "Beginning NDNP batch ingest..."
    ingester.ingest
    puts "NDNP batch ingest complete! See log/ingest.log for details."
  end

  desc 'Ingest a directory of PDF issues for a single publication: '\
    '"rake newspaper_works:ingest_pdf_issues -- --path="'
  task :ingest_issues do
    use_application
    ingester = NewspaperWorks::Ingest::BatchIssueIngester.from_command(
      ARGV,
      'rake newspaper_works:ingest_issues --'
    )
    puts "Beginning batch ingest of issues for single publication..."
    ingester.ingest
    puts "Ingest of issue(s) ingest complete, but may be pending background "\
         "jobs. See log/ingest.log for details."
  end

  # Aliases to media-specific task ingest names
  # rubocop:disable Style/HashSyntax
  task :ingest_pdf_issues => :ingest_issues
  task :ingest_tiff_issues => :ingest_issues
  task :ingest_jp2_issues => :ingest_issues
  # rubocop:enable Style/HashSyntax
end
