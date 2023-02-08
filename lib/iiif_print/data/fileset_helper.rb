module IiifPrint
  module Data
    # Mixin module for fileset methods for work, presumes an @work
    #   instance attribute refering to a work object
    module FilesetHelper
      def fileset_id
        # if context is itself a string, presume it is a file set id
        return @work if @work.is_a? String
        # if context is not a String, presume a work or fileset context:
        fileset.nil? ? nil : fileset.id
      end

      def first_fileset
        # if context is fileset id (e.g. caller is view partial) string,
        #   get the fileset from that id
        return FileSet.find(@work) if @work.is_a?(String)
        # if "work" context is a FileSet, not actual work, return it
        return @work if @work.is_a? FileSet
        # in most cases, get from work's members:
        filesets = @work.members.select { |m| m.is_a? FileSet }
        filesets.empty? ? nil : filesets[0]
      end
    end
  end
end
