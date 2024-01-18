module IiifPrint
  ##
  # The PersistenceLayer module provides the namespace for other adapters:
  #
  # - {IiifPrint::PersistenceLayer::ActiveFedoraAdapter}
  # - {IiifPrint::PersistenceLayer::ValkyrieAdapter}
  #
  # And the defining interface in the {IiifPrint::PersistenceLayer::AbstractAdapter}
  module PersistenceLayer
    # @abstract
    class AbstractAdapter
      ##
      # @abstract
      def self.parent_for(*); end

      ##
      # @abstract
      def self.grandparent_for(*); end

      ##
      # @abstract
      def self.solr_field_query(*); end

      ##
      # @abstract
      def self.clean_for_tests!
        return false unless Rails.env.test?
        yield
      end

      ##
      # @abstract
      def self.solr_query(*args); end

      ##
      # @abstract
      def self.solr_name(*args); end
    end
  end
end
