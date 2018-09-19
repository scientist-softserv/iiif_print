require 'spec_helper'

# based on: https://github.com/samvera/hyrax/blob/89ffdb757a7ae545e303919d2277901237a5fd30/spec/views/records/edit_fields/_based_near.html.erb_spec.rb
RSpec.describe 'records/edit_fields/_place_of_publication.html.erb', type: :view do
  let(:title) { NewspaperTitle.new }
  let(:form) { Hyrax::NewspaperTitleForm.new(title, nil, controller) }
  let(:form_template) do
    %(
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render "records/edit_fields/place_of_publication", f: f, key: 'place_of_publication' %>
      <% end %>
    )
  end

  before do
    assign(:form, form)
    render inline: form_template
  end

  it 'has url for autocomplete service' do
    expect(rendered).to have_selector('input[data-autocomplete-url="/authorities/search/geonames"][data-autocomplete="place_of_publication"]')
  end
  it 'has input for linked data URI' do
    expect(rendered).to have_selector('#newspaper_title_place_of_publication_attributes_0_id', visible: :hidden)
  end
end
