module IiifPrint
  class NewspaperCoreFormData < Hyrax::Forms::WorkForm
    self.terms += [:resource_type, :place_of_publication, :issn, :lccn,
                   :oclcnum, :held_by]
    self.terms -= [:based_near, :date_created, :keyword, :related_url, :source]
    self.required_fields += [:resource_type, :language, :held_by]
    self.required_fields -= [:creator, :keyword, :rights_statement]

    def self.build_permitted_params
      super + [
        {
          place_of_publication_attributes: [:id, :_destroy]
        }
      ]
    end
  end
end
