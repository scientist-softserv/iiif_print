# module comment...
module NewspaperWorks
  # setting this allows us to use GeoNames autocomplete for place_of_publication property
  # needs to be included in models after Hyrax::BasicMetadata
  module PlaceOfPublicationBehavior
    extend ActiveSupport::Concern

    included do
      self.controlled_properties = [:place_of_publication]
      accepts_nested_attributes_for :place_of_publication,
                                    reject_if: proc { |attributes| attributes[:id].blank? },
                                    allow_destroy: true
    end
  end
end
