module NewspaperWorks
  class JP2ImageMetadata
    TOKEN_MARKER_START = "\xFF".force_encoding("BINARY").freeze
    TOKEN_MARKER_SIZ = "\x51".force_encoding("BINARY").freeze
    TOKEN_IHDR = 'ihdr'.freeze

    attr_accessor :path

    def initialize(path)
      @path = path
    end

    # @param io [IO] IO stream opened in binary mode, for reading
    # @return [Array(Integer, Integer)] X size, Y size, in Integer-typed px
    def extract_jp2_dim(io)
      raise IOError, 'file not open in binary mode' unless io.binmode?
      buffer = ''
      siz_found = false
      # Informed by ISO/IEC 15444-1:2000, pp. 26-27
      #   via:
      #   http://hosting.astro.cornell.edu/~carcich/LRO/jp2/ISO_JPEG200_Standard/INCITS+ISO+IEC+15444-1-2000.pdf
      #
      # first 23 bytes are file-magic, we can skip
      io.seek(23, IO::SEEK_SET)
      while !siz_found && !buffer.nil?
        # read one byte at a time, until we hit marker start 0xFF
        buffer = io.read(1) while buffer != TOKEN_MARKER_START
        # - on 0xFF read subsequent byte; if value != 0x51, continue
        buffer = io.read(1)
        next if buffer != TOKEN_MARKER_SIZ
        # - on 0x51, read next 12 bytes
        buffer = io.read(12)
        siz_found = true
      end
      # discard first 4 bytes; next 4 bytes are XSiz; last 4 bytes are YSiz
      x_siz = buffer.byteslice(4, 4).unpack('N').first
      y_siz = buffer.byteslice(8, 4).unpack('N').first
      [x_siz, y_siz]
    end

    # @param io [IO] IO stream opened in binary mode, for reading
    # @return [Array(Integer, Integer)] number components, bits-per-component
    def extract_jp2_components(io)
      raise IOError, 'file not open in binary mode' unless io.binmode?
      io.seek(0, IO::SEEK_SET)
      # IHDR should be in first 64 bytes
      buffer = io.read(64)
      ihdr_data = buffer.split(TOKEN_IHDR)[-1]
      raise IOError if ihdr_data.nil?
      num_components = ihdr_data.byteslice(8, 2).unpack('n').first
      # stored as "bit depth of the components in the codestream, minus 1", so add 1
      bits_per_component = ihdr_data.byteslice(10, 1).unpack('c').first + 1
      [num_components, bits_per_component]
    end

    def validate_jp2(io)
      # verify file is jp2
      magic = io.read(23)
      raise IOError, 'Not JP2 file' unless magic.end_with?('ftypjp2')
    end

    # @param path [String] path to jp2, for reading
    # @return [Hash] hash
    def technical_metadata
      io = File.open(path, 'rb')
      io.seek(0, IO::SEEK_SET)
      validate_jp2(io)
      x_siz, y_siz = extract_jp2_dim(io)
      nc, bpc = extract_jp2_components(io)
      color = nc >= 3 ? 'color' : 'gray'
      io.close
      {
        color: bpc == 1 ? 'monochrome' : color,
        num_components: nc,
        bits_per_component: bpc,
        width: x_siz,
        height: y_siz
      }
    end
  end
end
