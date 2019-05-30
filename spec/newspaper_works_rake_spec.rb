require 'spec_helper'
require 'rake'
require 'ndnp_shared'
require 'active_fedora/cleaner'

# rubocop:disable RSpec/DescribeClass
describe 'newspaper_works rake tasks' do
  include_context 'ndnp fixture setup'

  before(:all) do
    Rake.application.rake_require '../lib/tasks/newspaper_works_tasks'
    Rake::Task.define_task(:environment)
  end

  describe 'ingest tasks' do
    before(:all) do
      ActiveFedora::Cleaner.clean!
      Hyrax::PermissionTemplateAccess.destroy_all
      Hyrax::PermissionTemplate.destroy_all
    end

    let(:run_ndnp_ingest_task) do
      task = 'newspaper_works:ingest_ndnp'
      stub_const(
        'ARGV',
        [
          'newspaper_works:ingest_ndnp',
          '--',
          "--path=#{batch1}"
        ]
      )
      Rake::Task[task].reenable
      Rake.application.invoke_task(task)
    end

    def expect_clean_slate
      expect(NewspaperTitle.all.to_a).to be_empty
      expect(NewspaperIssue.all.to_a).to be_empty
      expect(NewspaperPage.all.to_a).to be_empty
    end

    def expect_generated_issues(publication)
      batch = NewspaperWorks::Ingest::NDNP::BatchXMLIngest.new(batch1)
      relevant = batch.select { |i| i.metadata.lccn == publication.lccn }
      issue_dates = relevant.map(&:publication_date)
      expect(publication.issues.size).to eq issue_dates.size
      expect(publication.issues.map(&:publication_date)).to \
        match_array issue_dates
    end

    def expect_generated_content(lccn_list)
      lccn_list.each do |lccn|
        # expect title work for LCCN
        publication = NewspaperTitle.where(lccn: lccn).first
        expect(publication).not_to be_nil
        # expect title to have issue children
        issues = publication.issues.to_a
        expect(issues).not_to be_empty
      end
    end

    def check_pages(lccns)
      # quick verification of pages imported:
      pages = NewspaperPage.all
      expect(pages.size).to eq 5
      pages.each do |page|
        lccn = page.publication.lccn
        expect(lccns).to include lccn
      end
    end

    it 'successfully ingests NDNP batch by task' do
      pub_lccns = ['sn84038814', 'sn85025202']
      expect_clean_slate
      run_ndnp_ingest_task
      # the batch we test has two titles, verify all content for each:
      expect_generated_content(pub_lccns)
      check_pages(pub_lccns)
    end
  end
end
# rubocop:enable RSpec/DescribeClass
