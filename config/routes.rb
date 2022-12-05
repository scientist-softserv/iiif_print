IiifPrint::Engine.routes.draw do
  # Chronicling America-style linking
  get 'newspapers/:unique_id', to: 'newspapers#title', as: 'newspaper_title'
  get 'newspapers/:unique_id/:date', to: 'newspapers#issue', as: 'newspaper_issue'
  get 'newspapers/:unique_id/:date/:edition', to: 'newspapers#issue', as: 'newspaper_issue_edition'
  get 'newspapers/:unique_id/:date/:edition/:page', to: 'newspapers#page', as: 'newspaper_page'

  get 'newspapers_search', to: 'newspapers_search#search', as: 'newspapers_search'
end
