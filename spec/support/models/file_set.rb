##
# iiif_print requires a file set model that is compatible with Hyrax assumptions.  We do not want to
# add this to app/models because those are loaded in the downstream application; which can create
# unexpected surprises.
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
end
