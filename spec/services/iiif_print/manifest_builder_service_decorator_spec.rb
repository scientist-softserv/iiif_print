# frozen_string_literal: true
require 'spec_helper'

RSpec.describe IiifPrint::ManifestBuilderServiceDecorator do
  context '#initialize' do
    it 'uses defaults to set the version' do
      builder_service = Hyrax::ManifestBuilderService.new
      expect(builder_service.manifest_factory).to eq(::IIIFManifest::ManifestFactory)
      expect(builder_service.version).to eq(IiifPrint.config.default_iiif_manifest_version)
    end

    it 'allows version overrides' do
      # This in part verifies the expected interaction of the version as a parameter being picked up
      # by another parameter.
      builder_service = Hyrax::ManifestBuilderService.new(version: 3)
      expect(builder_service.manifest_factory).to eq(::IIIFManifest::V3::ManifestFactory)
      expect(builder_service.version).to eq(3)
    end
  end
end
