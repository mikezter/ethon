module Ethon
  module Curl
    # :nodoc:
    class MsgData < ::FFI::Union
      layout :whatever, :pointer, :code, :easy_code
    end

    # :nodoc:
    class Msg < ::FFI::Struct
      layout :code, :msg_code, :easy_handle, :pointer, :data, MsgData
    end

    # :nodoc:
    #
    # @api private
    def Curl.windows?
      !(RbConfig::CONFIG['host_os'] !~ /mingw|mswin|bccwin/)
    end

    # :nodoc:
    class FDSet < ::FFI::Struct
      # XXX how does this work on non-windows? how can curl know the new size...
      FD_SETSIZE = 524288 # set a higher maximum number of fds. this has never applied to windows, so just use the default there

      if Curl.windows?
        layout :fd_count, :u_int,
               :fd_array, [:u_int, 64] # 2048 FDs

        def clear; self[:fd_count] = 0; end
      else
        layout :fds_bits, [:long, FD_SETSIZE / ::FFI::Type::LONG.size]

        # :nodoc:
        def clear; super; end
      end
    end

    # :nodoc:
    class Timeval < ::FFI::Struct
      layout :sec, :time_t,
             :usec, :suseconds_t
    end
  end
end
