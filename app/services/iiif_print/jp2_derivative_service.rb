require 'open3'

module IiifPrint
  class JP2DerivativeService < PageDerivativeService
    # OpenJPEG 2000 Command to make NDNP-compliant grayscale JP2:
    CMD_GRAY = 'opj_compress -i %<source_file>s -o %<out_file>s ' \
              '-d 0,0 -b 64,64 -n 6 -p RLCP -t 1024,1024 -I -M 1 ' \
              '-r 64,53.821,45.249,40,32,26.911,22.630,20,16,14.286,' \
              '11.364,10,8,6.667,5.556,4.762,4,3.333,2.857,2.500,2,' \
              '1.667,1.429,1.190,1'.freeze

    # OpenJPEG 2000 Command to make RGB JP2:
    CMD_COLOR = 'opj_compress -i %<source_file>s -o %<out_file>s ' \
                '-d 0,0 -b 64,64 -n 6 -p RPCL -t 1024,1024 -I -M 1 '\
                '-r 2.4,1.48331273,.91673033,.56657224,.35016049,.21641118,' \
                '.13374944,.0944,.08266171'.freeze

    # OpenJPEG 1.x command replacement for 2.x opj_compress, takes same options;
    #   this is necessary on Ubuntu Trusty (e.g. Travis CI)
    CMD_1X = 'image_to_j2k'.freeze

    # Target file extension of this service plugin:
    TARGET_EXT = 'jp2'.freeze

    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    def initialize(file_set)
      # cached result string for imagemagick `identify` command
      @command = nil
      @unlink_after_creation = []
      super(file_set)
    end

    def create_derivatives(filename)
      # Base class takes care of loading @source_path, @dest_path
      super(filename)

      # no creation if jp2 master => deemed unnecessary/duplicative
      return if mime_type == 'image/jp2'

      # if we have a non-TIFF source, or a 1-bit monochrome source, we need
      #   to make a NetPBM-based intermediate (temporary) file for OpenJPEG
      #   to consume.
      needs_intermediate = !tiff_source? || one_bit?

      # We use either intermediate temp file, or temp symlink (to work
      #   around OpenJPEG 2000 file naming quirk).
      needs_intermediate ? make_intermediate_source : make_symlink

      # Get OpenJPEG command, rendered with source, destination, appropriate
      #   to either color or grayscale source
      render_cmd = opj_command

      # Run the generated command to make derivative file at @dest_path
      `#{render_cmd}`

      # Clean up any intermediate files or symlinks used during creation
      cleanup_intermediate
    end

    private

    # source introspection:

    def tiff_source?
      identify[:content_type] == 'image/tiff'
    end

    def make_symlink
      # OpenJPEG binaries have annoying quirk of only using TIFF input
      #   files whose name ends in .TIF or .tif (three letter); for all
      #   non-monochrome TIFF files, we just assume we need to symlink
      #   to such a filename.
      tmpname = File.join(Dir.tmpdir, "#{SecureRandom.uuid}.tif")
      FileUtils.ln_s(@source_path, tmpname)
      @unlink_after_creation.push(tmpname)
      # finally, point @source_path for command at intermediate link:
      @source_path = tmpname
    end

    def make_intermediate_source
      # generate a random filename to be made, with appropriate extension,
      #   inside /tmp dir:
      tmpname = File.join(
        Dir.tmpdir,
        format(
          "#{SecureRandom.uuid}.%<ext>s",
          ext: use_color? ? 'ppm' : 'pgm'
        )
      )
      # if pdf source, get only first page
      source_path = @source_path
      source_path += '[0]' if @source_path.ends_with?('pdf')
      # Use ImageMagick `convert` to create intermediate bitmap:
      `convert #{source_path} #{tmpname}`
      @unlink_after_creation.push(tmpname)
      # finally, point @source_path for command at intermediate file:
      @source_path = tmpname
    end

    def opj_command
      # Get a command template appropriate to OpenJPEG 1.x or 2.x
      use_openjpeg_1x = `which opj_compress`.empty?
      cmd = use_color? ? CMD_COLOR : CMD_GRAY
      cmd = cmd.sub('opj_compress', 'image_to_j2k') if use_openjpeg_1x
      # return command with source and destination file names injected
      format(cmd, source_file: @source_path, out_file: @dest_path)
    end

    def cleanup_intermediate
      # remove symlink or intermediate file once we no longer need
      @unlink_after_creation.each do |path|
        FileUtils.rm(path)
      end
    end
  end
end
