require 'spec_helper'
# require 'model_shared'
RSpec.describe 'hyrax/newspaper_titles/_issue_calendar.html.erb', type: :view do
  let!(:issues) do
    [
      SolrDocument.new(id: '123',
                       publication_date_dtsi: '2019-02-13T:00:00:00Z'),
      SolrDocument.new(id: '456',
                       publication_date_dtsi: '2019-03-05T:00:00:00Z')
    ]
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
      links[Date.parse(issue["publication_date_dtsi"]).strftime("%-d")] = hyrax_newspaper_issue_path(issue)
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
