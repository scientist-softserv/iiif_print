# a set of Title, Issue, and Page objects that can be reused in feature specs
RSpec.shared_context "fixtures_for_features", shared_context: :metadata do
  # use this so titles are different every time spec is run
  # prevents tests from accidentally failing because search results view only shows 10 results
  # and our newly created fixtures may not show up on first results page
  title_base = 'Mxyzptlk'.chars.shuffle.join
  title1_title = "#{title_base} Examiner"
  title1_issue1_title = "#{title1_title}: July 4, 1965"
  title2_title = "#{title_base} Courier"
  title2_issue1_title = "#{title2_title}: July 4, 1969"

  # memo-ize these so we can use it in specs
  let!(:title_base_memo) { title_base }
  let!(:title1_issue1_title_memo) { title1_issue1_title }
  let!(:title2_issue1_title_memo) { title2_issue1_title }

  # we use instance var for @title1 so we can access its id in specs
  # # use before(:all) so we only create fixtures once
  # rubocop:disable RSpec/InstanceVariable
  before(:all) do
    @title1 = NewspaperTitle.new
    @title1.title = [title1_title]
    @title1.lccn = 'sn0000000'
    @title1.visibility = 'open'

    title1_issue1 = NewspaperIssue.new
    title1_issue1.title = [title1_issue1_title]
    title1_issue1.resource_type = ["newspaper"]
    title1_issue1.language = ["English"]
    title1_issue1.held_by = "Marriott Library"
    title1_issue1.publication_date = '1965-07-04'
    title1_issue1.visibility = 'open'
    @title1.members << title1_issue1

    title1_issue1_page1 = NewspaperPage.new
    title1_issue1_page1.title = ["#{title1_issue1_title}: Page 1"]
    title1_issue1_page1.visibility = 'open'
    title1_issue1_page2 = NewspaperPage.new
    title1_issue1_page2.title = ["#{title1_issue1_title}: Page 2"]
    title1_issue1_page2.visibility = 'open'
    title1_issue1.ordered_members << title1_issue1_page1
    title1_issue1.ordered_members << title1_issue1_page2

    title1_issue1.save
    @title1.save
    title1_issue1_page1.save
    title1_issue1_page2.save

    title2 = NewspaperTitle.new
    title2.title = [title2_title]
    title2.lccn = 'sn1111111'
    title2.visibility = 'open'

    title2_issue1 = NewspaperIssue.new
    title2_issue1.title = [title2_issue1_title]
    title2_issue1.resource_type = ["newspaper"]
    title2_issue1.language = ["Spanish"]
    title2_issue1.held_by = "Boston Public Library"
    title2_issue1.publication_date = '1969-07-04'
    title2_issue1.visibility = 'open'
    title2.members << title2_issue1

    title2_issue1_page1 = NewspaperPage.new
    title2_issue1_page1.title = ["#{title2_issue1_title}: Page 1"]
    title2_issue1_page1.visibility = 'open'
    title2_issue1.ordered_members << title2_issue1_page1

    title2_issue1.save
    title2.save
    title2_issue1_page1.save
  end
  # rubocop:enable RSpec/InstanceVariable
end
