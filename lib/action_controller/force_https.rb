module ActionController
  # Modified version of Rails' force_ssl. Active in development Rails environment. Also uses 
  # old ssl_requirement behavior that builds full URL.
  module ForceHTTPS
    extend ActiveSupport::Concern
    include AbstractController::Callbacks

    module ClassMethods
      # Force the request to this particular controller or specified actions to be
      # under HTTPS protocol.
      #
      # ==== Options
      # * <tt>only</tt>   - The callback should be run only for this action
      # * <tt>except<tt>  - The callback should be run for all actions except this action
      def force_https(options = {})
        host = options.delete(:host)
        before_filter(options) do
          if !request.ssl? && RacingAssociation.current.ssl?
            redirect_to "https://#{request.host}#{request.original_fullpath}", :status => :moved_permanently
            flash.keep
            return false
          end
        end
      end
    end
  end
end
