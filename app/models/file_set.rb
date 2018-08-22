# ---
# newspaper_works needs a fileset compatible with and mixing in
# ::Hyrax::FileSetBehavior, since Hyrax does not define such a class.
# Typically, this is provided by boilerplate Hyrax generates into an
# app, but this engine provides a compatible FileSet class for use
# and instantiaion by its models.
# ---
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
end
