require 'ethon/multi/stack'
require 'ethon/multi/operations'
require 'ethon/multi/options'

module Ethon

  # This class represents libcurl multi.
  class Multi
    include Ethon::Multi::Stack
    include Ethon::Multi::Operations
    include Ethon::Multi::Options

    class << self

      # Frees the libcurl multi handle.
      #
      # @example Free multi.
      #   Multi.finalizer(multi)
      #
      # @param [ Multi ] multi The multi to free.
      def finalizer(multi)
        proc {
          Curl.multi_cleanup(multi.handle)
        }
      end
    end

    # Create a new multi. Initialize curl in case
    # it didn't happen before.
    #
    # @example Create a new Multi.
    #   Multi.new
    #
    # @param [ Hash ] options The options.
    #
    # @option options :socketdata [String]
    #  Pass a pointer to whatever you want passed to the
    #  curl_socket_callback's forth argument, the userp pointer. This is not
    #  used by libcurl but only passed-thru as-is. Set the callback pointer
    #  with CURLMOPT_SOCKETFUNCTION.
    # @option options :pipelining [Boolean]
    #  Pass a long set to 1 to enable or 0 to disable. Enabling pipelining
    #  on a multi handle will make it attempt to perform HTTP Pipelining as
    #  far as possible for transfers using this handle. This means that if
    #  you add a second request that can use an already existing connection,
    #  the second request will be "piped" on the same connection rather than
    #  being executed in parallel. (Added in 7.16.0)
    # @option options :timerfunction [Proc]
    #  Pass a pointer to a function matching the curl_multi_timer_callback
    #  prototype. This function will then be called when the timeout value
    #  changes. The timeout value is at what latest time the application
    #  should call one of the "performing" functions of the multi interface
    #  (curl_multi_socket_action(3) and curl_multi_perform(3)) - to allow
    #  libcurl to keep timeouts and retries etc to work. A timeout value of
    #  -1 means that there is no timeout at all, and 0 means that the
    #  timeout is already reached. Libcurl attempts to limit calling this
    #  only when the fixed future timeout time actually changes. See also
    #  CURLMOPT_TIMERDATA. This callback can be used instead of, or in
    #  addition to, curl_multi_timeout(3). (Added in 7.16.0)
    # @option options :timerdata [String]
    #  Pass a pointer to whatever you want passed to the
    #  curl_multi_timer_callback's third argument, the userp pointer. This
    #  is not used by libcurl but only passed-thru as-is. Set the callback
    #  pointer with CURLMOPT_TIMERFUNCTION. (Added in 7.16.0)
    # @option options :maxconnects [Integer]
    #  Pass a long. The set number will be used as the maximum amount of
    #  simultaneously open connections that libcurl may cache. Default is
    #  10, and libcurl will enlarge the size for each added easy handle to
    #  make it fit 4 times the number of added easy handles.
    #  By setting this option, you can prevent the cache size from growing
    #  beyond the limit set by you.
    #  When the cache is full, curl closes the oldest one in the cache to
    #  prevent the number of open connections from increasing.
    #  This option is for the multi handle's use only, when using the easy
    #  interface you should instead use the CURLOPT_MAXCONNECTS option.
    #  (Added in 7.16.3)
    #
    #
    # @return [ Multi ] The new multi.
    def initialize(options = {})
      Curl.init
      ObjectSpace.define_finalizer(self, self.class.finalizer(self))
      set_attributes(options)
      init_vars
    end

    # Set given options.
    #
    # @example Set options.
    #   multi.set_attributes(options)
    #
    # @raise InvalidOption
    #
    # @see initialize
    def set_attributes(options)
      options.each_pair do |key, value|
        unless respond_to?("#{key}=")
          raise Errors::InvalidOption.new(key)
        end
        method("#{key}=").call(value)
      end
    end
  end
end
