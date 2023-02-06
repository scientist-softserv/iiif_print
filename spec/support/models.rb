####################################################################################################
#
# The purpose of this file is to define the models we'll use in our spec application.  Some of these
# models are echoes of what downstream apps will define (e.g. FileSet).  Other are for internal
# modeling purposes only.
#
####################################################################################################

##
# iiif_print requires a file set model that is compatible with Hyrax assumptions.  We do not want to
# add this to app/models because those are loaded in the downstream application; which can create
# unexpected surprises.
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
end


# Newspaper Issue
class NewspaperIssue < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata
end
