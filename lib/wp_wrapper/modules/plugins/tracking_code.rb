module WpWrapper
  module Modules
    module Plugins
      module TrackingCode
      
        def configure_tracking_code(tracking_code)
          options   =   {
            'data[tracking_head][code]'       =>  {:value     =>  tracking_code,  :type   =>  :input}, 
            'data[tracking_head][disable]'    =>  {:checked   =>  false,          :type   =>  :checkbox},
            'data[tracking_footer][code]'     =>  {:value     =>  '',             :type   =>  :input}, 
            'data[tracking_footer][disable]'  =>  {:checked   =>  true,           :type   =>  :checkbox},
          }
        
          return set_options_and_submit("options-general.php?page=tracking-code", {:method => /post/i}, options)
        end
      
      end
    end
  end
end