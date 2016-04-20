module WpWrapper
  module Modules
    module Plugins
      module W3TotalCache
      
        def configure_w3_total_cache(caching_mechanism = :memcached, options = {})
          configure_general_settings(caching_mechanism, options)
          configure_page_cache
          configure_minification(options.fetch(:minify, {}))
          configure_browser_cache
          activate_configuration
        end
      
        def configure_general_settings(caching_mechanism, options = {})
          caching_options           =   {}
          cache_sections            =   [:pg, :db, :object]
        
          url                       =   "admin.php?page=w3tc_general"
          form_identifier           =   {:id => 'w3tc_form'}
          button_identifier         =   {:name => 'w3tc_save_options'}
        
          varnish_server            =   options.fetch(:varnish_server, "localhost")
        
          cache_sections.each do |cache_section|
            section_options         =   {
              "#{cache_section}cache.enabled"    =>    {:checked   =>  true,               :type   =>  :checkbox}, 
              "#{cache_section}cache.engine"     =>    {:value     =>  caching_mechanism,  :type   =>  :select}
            }
          
            caching_options.merge!(section_options)
          end
        
          minify_options            =   {
            "minify.enabled"    =>    {:checked   =>  true,               :type   =>  :checkbox}, 
            "minify.engine"     =>    {:value     =>  caching_mechanism,  :type   =>  :select},
          }
        
          caching_options.merge!(minify_options)
        
          browser_cache_options     =   {
            "browsercache.enabled"          =>    {:checked   =>  true,               :type   =>  :checkbox},
          }
        
          caching_options.merge!(browser_cache_options)
        
          varnish_options           =   {
            "varnish.enabled"               =>    {:checked   =>  true,               :type   =>  :checkbox},
            "varnish.servers"               =>    {:value     =>  varnish_server,     :type   =>  :input}
          }
        
          caching_options.merge!(varnish_options)
        
          return set_options_and_submit(url, form_identifier, caching_options, button_identifier)
        end
      
        def configure_page_cache
          url                       =   "admin.php?page=w3tc_pgcache"
          form_identifier           =   {:action => /admin\.php\?page=w3tc_pgcache/i, :index => 1}
          button_identifier         =   {:name => 'w3tc_save_options'}
        
          options                   =   {
            "pgcache.cache.feed"            =>    {:checked   =>  true,                 :type   =>  :checkbox},
          }
        
          return set_options_and_submit(url, form_identifier, options, button_identifier)
        end
      
        def configure_minification(options = {})
          url                       =   "admin.php?page=w3tc_minify"
          form_identifier           =   {:action => /admin\.php\?page=w3tc_minify/i, :index => 1}
          button_identifier         =   {:name => 'w3tc_save_options'}
          
          minify_html               =   options.fetch(:html, :enable).to_sym.eql?(:enable)
          minify_inline_css         =   options.fetch(:inline_css, :enable).to_sym.eql?(:enable)
          minify_inline_js          =   options.fetch(:inline_js, :enable).to_sym.eql?(:enable)

          minify_js                 =   options.fetch(:js, :enable).to_sym.eql?(:enable)
          minify_css                =   options.fetch(:css, :enable).to_sym.eql?(:enable)
        
          options                   =   {
            "minify.html.enable"                          =>    {:checked   =>  minify_html,          :type   =>  :checkbox},
            "minify.html.inline.css"                      =>    {:checked   =>  minify_inline_css,    :type   =>  :checkbox},
            "minify.html.inline.js"                       =>    {:checked   =>  minify_inline_js,     :type   =>  :checkbox},
            "minify.auto.disable_filename_length_test"    =>    {:checked   =>  true,                 :type   =>  :checkbox},
            
            "minify.js.enable"                            =>    {:checked   =>  minify_js,            :type   =>  :checkbox},
            "minify.css.enable"                           =>    {:checked   =>  minify_css,           :type   =>  :checkbox},
          }
        
          return set_options_and_submit(url, form_identifier, options, button_identifier)
        end
      
        def configure_browser_cache
          options                   =   {}
        
          url                       =   "admin.php?page=w3tc_browsercache"
          form_identifier           =   {:action => /admin\.php\?page=w3tc_browsercache/i, :index => 1}
          button_identifier         =   {:name => 'w3tc_save_options'}
        
          sections                  =   [
            :cssjs, :html, :other
          ]
        
          sections.each do |section|
            section_options         =   {
              "browsercache.#{section}.expires"           =>    {:checked   =>  true,               :type   =>  :checkbox}, 
              "browsercache.#{section}.cache.control"     =>    {:checked   =>  true,               :type   =>  :checkbox},
              "browsercache.#{section}.etag"              =>    {:checked   =>  true,               :type   =>  :checkbox},
            }
          
            options.merge!(section_options)
          end
        
          return set_options_and_submit(url, form_identifier, options)
        end
      
        def activate_configuration
          url         =   "#{get_url(:admin)}admin.php?page=w3tc_general"
          page        =   self.mechanize_client.get_page(url)
          
          parser      =   page      ?   self.mechanize_client.get_parser(page)      :   nil
          input       =   parser    ?   parser.at_css('input[value = "deploy"]')    :   nil
        
          if (input)
            on_click  =   input["onclick"]
            url       =   on_click.gsub("admin.php?page=w3tc_general", url)
            url       =   url.gsub(/^document\.location\.href='/i, "").gsub(/';$/, "")
          
            puts "Will activate new W3 Total Cache-configuration. Activation url: #{url}"
          
            self.http_client.retrieve_raw_content(url)
          end
        end
      
      end
    end
  end
end