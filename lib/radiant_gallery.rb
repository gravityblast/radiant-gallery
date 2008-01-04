unless defined? RadiantGallery::Version
  module RadiantGallery
    module Version
      Major = '0'
      Minor = '7'
      Tiny  = '7'
    
      class << self
        def to_s
          [Major, Minor, Tiny].join('.')
        end
        alias :to_str :to_s
      end
    end
    
    class << self
      def loaded_via_gem?
        !!(__FILE__ =~ %r{/gems/})        
      end
    end
  end
end
