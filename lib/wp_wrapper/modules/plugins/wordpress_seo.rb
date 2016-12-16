# encoding: UTF-8

module WpWrapper
  module Modules
    module Plugins
      module WordpressSeo
      
        def configure_wordpress_seo(language = :sv)
          login unless logged_in?
          
          puts "[WpWrapper::Modules::Plugins::WordpressSeo] - #{Time.now}: Starting configuration of Wordpress SEO / Yoast SEO."
          
          enable_wordpress_seo_settings_page
          configure_wordpress_seo_titles(language)
          configure_wordpress_seo_advanced_options
        end
        
        def enable_wordpress_seo_settings_page
          login unless logged_in?
        
          page      =   self.mechanize_client.get_page("#{get_url(:admin)}admin.php?page=wpseo_dashboard")
          form      =   self.mechanize_client.get_form(page, {action: /wp-admin\/options\.php/i})
          
          options   =   {
            "wpseo[enable_setting_pages]"      =>  {:type   =>  :checkbox,   :checked    =>  true},
            "wpseo[show_onboarding_notice]"    =>  {:type   =>  :checkbox,   :checked    =>  false}
          }
          
          response  =   submit_wordpress_seo_form(form, options)
        end
        
        def configure_wordpress_seo_titles(language = :sv)
          login unless logged_in?
        
          options   =   get_title_options(language)
          options.merge!(get_taxonomy_options)
          options.merge!(get_archive_options)
          options.merge!(get_other_options)

          url       =   "#{get_url(:admin)}admin.php?page=wpseo_titles"
          page      =   self.mechanize_client.get_page(url)
          form      =   self.mechanize_client.get_form(page, {action: /wp-admin\/options\.php/i})
          
          response  =   submit_wordpress_seo_form(form, options)
        end
        
        def configure_wordpress_seo_advanced_options
          login unless logged_in?
        
          configure_wordpress_seo_permalinks
        end
        
        def configure_wordpress_seo_permalinks
          url       =   "#{get_url(:admin)}admin.php?page=wpseo_advanced&tab=permalinks"
          page      =   self.mechanize_client.get_page(url)
          form      =   self.mechanize_client.get_form(page, {:action => /wp-admin\/options\.php/i})
        
          options   =   {
            "wpseo_permalinks[redirectattachment]"                    =>  {:type   =>  :checkbox,   :checked    =>  true},
            "wpseo_permalinks[cleanreplytocom]"                       =>  {:type   =>  :checkbox,   :checked    =>  true}
          }
          
          response    =   submit_wordpress_seo_form(form, options)
        end
        
        def configure_wordpress_seo_sitemaps(not_included_post_types: [:attachment], not_included_taxonomies: [:category, :post_tag, :post_format], disable_author_sitemap: true)
          login unless logged_in?
          
          url       =   "#{get_url(:admin)}admin.php?page=wpseo_xml"
          page      =   self.mechanize_client.get_page(url)
          form      =   self.mechanize_client.get_form(page, {:action => /wp-admin\/options\.php/i})
          
          options   =   {
            "wpseo_xml[enablexmlsitemap]"                             =>  {:type   =>  :checkbox,   :checked    =>  true}
          }
          
          if disable_author_sitemap
            options["wpseo_xml[disable_author_sitemap]"]              =   {:type   =>  :checkbox,   :checked    =>  true}
          end
          
          not_included_post_types.each do |post_type|
            post_type_options = {
              "wpseo_xml[post_types-#{post_type}-not_in_sitemap]"     =>  {:type   =>  :checkbox,   :checked    =>  true}
            }
          
            options.merge!(post_type_options)
          end
          
          not_included_taxonomies.each do |taxonomy|
            taxonomy_options = {
              "wpseo_xml[taxonomies-#{taxonomy}-not_in_sitemap]"      =>  {:type   =>  :checkbox,   :checked    =>  true}
            }
            
            options.merge!(taxonomy_options)
          end
          
          response    =   submit_wordpress_seo_form(form, options)
        end
        
        private
          def submit_wordpress_seo_form(form, options)
            page      =   nil
        
            if form
              options.each do |key, values|
                case values[:type]
                  when :input
                    form[key] = values[:value]
                  when :checkbox, :radiobutton
                    value     = values[:checked] ? "on" : "off"
                    form[key] = value
                end
              end
      
              page    =   form.submit
            end
          
            return page
          end
        
          def get_title_options(language = :sv)
            options                 =   {
              "wpseo_titles[title-home-wpseo]"          =>  {:type   =>  :input,      :value     =>  '%%sitename%% %%page%%'},
              "wpseo_titles[title-search-wpseo]"        =>  {:type   =>  :input,      :value     =>  translate_pattern(:search, language)},
              "wpseo_titles[title-404-wpseo]"           =>  {:type   =>  :input,      :value     =>  translate_pattern(:not_found, language)}
            }
          
            standard_pattern        =   '%%title%% %%page%% %%sep%% %%sitename%%'
            standard_term_pattern   =   translate_pattern(:term, language)
        
            types                   =   {
              :post           =>  {:pattern => standard_pattern,                              :noindex => false},
              :page           =>  {:pattern => standard_pattern,                              :noindex => false},
              :attachment     =>  {:pattern => standard_pattern,                              :noindex => true},
              :category       =>  {:pattern => standard_term_pattern,                         :noindex => true},
              :post_tag       =>  {:pattern => standard_term_pattern,                         :noindex => true},
              :post_format    =>  {:pattern => standard_term_pattern,                         :noindex => true},
              :author         =>  {:pattern => translate_pattern(:author, language),          :noindex => true},
              :archive        =>  {:pattern => '%%date%% %%page%% %%sep%% %%sitename%%',      :noindex => true},
            }
            
            extra_types             =   {
              :wooframework   =>  {:pattern => standard_pattern,                              :noindex => true},
            }
            
            types.merge!(extra_types)
        
            types.each do |key, values|
              form_key              =   [:category, :post_tag, :post_format].include?(key)  ?   "tax-#{key}"        : key
              form_key              =   [:author, :archive].include?(key)                   ?   "#{form_key}-wpseo" : form_key
            
              type_options          =   {
                "wpseo_titles[title-#{form_key}]"   =>  {:type   =>  :input,      :value      =>  values[:pattern]},
                "wpseo_titles[noindex-#{form_key}]" =>  {:type   =>  :checkbox,   :checked    =>  values[:noindex]}
              }
          
              options.merge!(type_options)
            end
          
            return options
          end
        
          def get_taxonomy_options
            options                 =   {
              "wpseo_titles[disable-post_format]"     =>  {:type   =>  :checkbox,   :checked   =>  true},
            }
          
            return options
          end
        
          def get_archive_options
            options                 =   {
              "wpseo_titles[disable-author]"          =>  {:type   =>  :checkbox,   :checked   =>  true},
              "wpseo_titles[disable-date]"            =>  {:type   =>  :checkbox,   :checked   =>  true},
            }
          end
          
          def get_other_options
            options                 =   {
              "wpseo_titles[noindex-subpages-wpseo]"  =>  {:type   =>  :checkbox,   :checked   =>  true},
            }
          end
      
          #Retarded method for now, look into I18n later
          def translate_pattern(key, language = :en)
            case key
              when :search
                language.eql?(:sv) ? 'Du sökte efter %%searchphrase%% %%page%% %%sep%% %%sitename%%' : 'You searched for %%searchphrase%% %%page%% %%sep%% %%sitename%%'
              when :not_found
                language.eql?(:sv) ? 'Sidan kunde inte hittas %%sep%% %%sitename%%' : 'Page Not Found %%sep%% %%sitename%%'
              when :author
                language.eql?(:sv) ? '%%name%%, Författare %%sitename%% %%page%%' : '%%name%%, Author at %%sitename%% %%page%%'
              when :term
                language.eql?(:sv) ? '%%term_title%% Arkiv %%page%% %%sep%% %%sitename%%' : '%%term_title%% Archives %%page%% %%sep%% %%sitename%%'
            end
          end
      
      end
    end
  end
end