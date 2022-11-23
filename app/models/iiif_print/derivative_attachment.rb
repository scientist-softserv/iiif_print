module IiifPrint
  class DerivativeAttachment < ApplicationRecord
    # We can store nil/optional fileset as interim value before fileset
    #   construction, but we require at minimum, path, destination_name
    validates :path, presence: true
    validates :destination_name, presence: true
  end
end
