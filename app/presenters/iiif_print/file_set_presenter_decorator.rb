# frozen_string_literal: true

module IiifPrint
  module FileSetPresenterDecorator
    # uses Hyku's TenantConfig to determine whether to allow PDF splitting button
    def show_split_button?
      return parent.try(:split_pdfs?) if parent.respond_to?(:split_pdfs?)
      true
    end
  end
end