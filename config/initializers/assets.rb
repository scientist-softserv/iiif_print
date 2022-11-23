# autocomplete_fix needs to be loaded inline, so it is not included in any asset manifest
Rails.application.config.assets.precompile += %w[iiif_print/autocomplete_fix.js]
