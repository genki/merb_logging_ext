# NOTE the original codes came from Merb 1.0.9-1.0.10.

module Merb
  class Request
   
    # NOTE the original code of Merb::Request#handle is defined in merb-core/dispatch/dispatcher.rb

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
          %r{^#{File.expand_path gem_path}/gems/([^/]*-\d+\.\d+\.\d+)/(.*)$}.freeze 
        }.freeze
      MERB_ROOT_REGEXP = /^#{Merb.root}(.*)$/.freeze
      SPECFILE_REGEXP = /_spec\.rb:(\d*?)$/.freeze
    end


    #NOTE The original code of Merb.exception is defined in merb-core/controller/exception.rb

    # Required to show exceptions in the log file
    #
    # Modified to omit GEM_PATH, if the most import thing is performance this change seems not good.
    # It is ok especially when the environment is development.
    #
    # e<Exception>:: The exception that a message is being generated for
    #
    # :api: plugin
    def self.exception(e)
      no_color = false # TODO need a option to choose whether colorize or not.
      backtrace = e.backtrace.dup or []
      backtrace.map! do |path|
        if m = Merb::Const::GEM_PATH_REGEXPS.map{|regex| path.match regex }.find{|m| m != nil }
          # gem_name_with_version = m[1]
          # relative_path = m[2]
          gem_name = no_color ? m[1] : Colorful.yellow(m[1])
          "#{gem_name}:#{m[2]}"
        elsif m = path.match( Merb::Const::MERB_ROOT_REGEXP )
          merb_root_name = no_color ? "Merb.root" : Colorful.red("Merb.root")
          "#{merb_root_name}:#{m[1]}" 
        elsif m = path.match( Merb::Const::SPECFILE_REGEXP )
          no_color ? path : Colorful.blue(path)
        else
          path
        end
      end
      "#{ e.message } - (#{ e.class })\n" <<  
      "#{backtrace.join("\n")}"
    end

  end
end
