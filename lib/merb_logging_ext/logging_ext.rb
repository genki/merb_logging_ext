# Most of this feature is extending Merb::Request#handle
module Merb
  class Request
    # NOTE: the original method of this came from Merb 1.0.9.
    # Handles request routing and action dispatch.
    # 
    # ==== Returns
    # Merb::Controller:: the controller that handled the action dispatch.
    # 
    # :api: private
    def handle
      start = Time.now
      _logging_start(start)
      
      find_route!
      return rack_response if handled?
      
      klass = controller
      _logging_before_dispatch_action
      
      unless klass < Controller
        raise NotFound, 
          "Controller '#{klass}' not found.\n" \
          "If Merb tries to find a controller for static files, " \
          "you may need to check your Rackup file, see the Problems " \
          "section at: http://wiki.merbivore.com/pages/rack-middleware"
      end
      
      if klass.abstract?
        raise NotFound, "The '#{klass}' controller has no public actions"
      end
      
      controller = dispatch_action(klass, params[:action])
      controller._benchmarks[:dispatch_time] = Time.now - start
      Merb.logger.info { controller._benchmarks.inspect }
      return _response_for_logging = controller.rack_response
    rescue Object => exception
      return _response_for_logging = dispatch_exception(exception).rack_response
    ensure
      _logging_after_dispatch_action _response_for_logging
      Merb.logger.flush
    end

    private

    chainable do

      def _logging_start(start)
        Merb.logger.info "Started request handling: #{start.strftime("%d %b.%Y %H:%M:%S")} "
        u = "Requested URI: " + full_uri 
        u << ( Merb::Const::QUESTION_MARK + query_string) unless query_string.blank?
        Merb.logger.info u
      end

      def _logging_before_dispatch_action
        if Merb::Plugins.config[:merb_logging_ext][:display_params_for_routing]
          Merb.logger.debug { "Routed to: #{params.inspect}" } 
        end
      end

      def _logging_after_dispatch_action(response)
        Merb.logger.info "Response-Headers: #{response[1].inspect}, Status-Code: #{response[0]}"
      end

    end
  end

  if Merb::Plugins.config[:merb_logging_ext][:display_parsed_backtrace]

    module Const
      GEM_PATH_REGEXPS = Gem.path.map{ |gem_path| 
          %r{^#{File.expand_path gem_path}/gems/([^/]*)-(\d+\.\d+\.\d+)/(.*)$}.freeze 
        }.freeze
    end

    # Required to show exceptions in the log file
    #
    # Modified to omit GEM_PATH, if the most import thing is performance this change seems not good.
    # It is ok especially when the environment is development.
    #
    # e<Exception>:: The exception that a message is being generated for
    #
    # :api: plugin
    def self.exception(e)
      color = true
      backtrace = e.backtrace.dup or []
      backtrace.map! do |path|
        Merb::Const::GEM_PATH_REGEXPS.inject(nil) do |omitted, regex|
          if omitted.nil? and m = path.match(regex) 
            # gem_name = m[1] or m[1].camel_case
            # gem_version = m[2]
            # relative_path = m[3]
            unless color 
              gem_name= "#{m[1]}-#{m[2]}"
            else
              gem_name= Colorful.yellow "#{m[1]}-#{m[2]}"
            end
            omitted = "#{gem_name}:#{m[3]}"
          end
          omitted
        end || path
      end
      "#{ e.message } - (#{ e.class })\n" <<  
      "#{backtrace.join("\n")}"
    end

  end
end
