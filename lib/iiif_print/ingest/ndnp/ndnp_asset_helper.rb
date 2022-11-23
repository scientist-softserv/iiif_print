module IiifPrint
  module Ingest
    module NDNP
      # Mixin for mets-specific XPath and traversal of issue/page data
      module NDNPAssetHelper
        # Set administrative metadata for asset, based on options saved
        #   on ingester state.
        # Pre-conditions for use:
        #   consuming class implements @target pointing to work asset
        #   consuming class implements @opts pointing to Hash
        def assign_administrative_metadata(work = nil)
          IiifPrint::Ingest.assign_administrative_metadata(
            work || @target,
            @opts
          )
        end
      end
    end
  end
end
