# make sure we're running inside Merb
if defined?(Merb::Plugins)

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_logging_ext] = {
    :display_params_for_routing => false,
    :display_parsed_backtrace => true
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
    require :merb_logging_ext / :logging_ext
    require :merb_logging_ext / :colorful
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  Merb::Plugins.add_rakefiles "merb_logging_ext/merbtasks"

end
