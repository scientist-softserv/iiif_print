# require 'model_shared'
RSpec.describe 'hyrax/newspaper_titles/_issue_calendar.html.erb', type: :view do
  let!(:issues) do
    issue1 = NewspaperIssue.new
    issue1.title = ['February 13, 2019']
    issue1.resource_type = ["newspaper"]
    issue1.language = ["eng"]
    issue1.held_by = "Marriott Library"
    issue1.publication_date = '2019-02-13'
    issue1.save
    issue2 = NewspaperIssue.new
    issue2.title = ['March 5, 2019']
    issue2.resource_type = ["newspaper"]
    issue2.language = ["eng"]
    issue2.held_by = "Marriott Library"
    issue2.publication_date = '2019-03-05'
    issue2.save
    [issue1.to_solr, issue2.to_solr]
  end

  let(:years) do
    { current: 2019, previous: nil, next: nil }
  end

  it 'shows calendar' do
    render partial: "issues_calendar.html.erb", locals: { issues: issues, years: years }
    expect(rendered).to have_content 'January'
  end

  it 'has link on dates with issues' do
    render partial: "issues_calendar.html.erb", locals: { issues: issues, years: years }
    links = {}
    issues.each do |issue|
      links[Date.parse(issue["publication_date_dtsim"].first).strftime("%-d")] = hyrax_newspaper_issue_path(issue)
    end
    links.each do |day, path|
      expect(rendered).to have_link(day, href: path)
    end
  end

  it 'displays the year' do
    render partial: "issues_calendar.html.erb", locals: { issues: issues, years: years }
    expect(rendered).to have_content "Issues: 2019"
  end
end
