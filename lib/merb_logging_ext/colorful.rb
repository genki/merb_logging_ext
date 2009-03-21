class Colorful
  class << self
  
    def red(msg)
      "\033[1;31m#{msg}\033[0m"
    end
    
    def yellow(msg)
      "\033[1;33m#{msg}\033[0m"
    end
    
    def green(msg)
      "\033[1;32m#{msg}\033[0m"
    end
    
    def magenta(msg)
      "\033[1;35m#{msg}\033[0m"
    end
    
    def blue(msg)
      "\033[1;34m#{msg}\033[0m"
    end

  end
end

