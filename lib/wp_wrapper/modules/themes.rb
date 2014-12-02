module WpWrapper
  module Modules
    module Themes
      
      def activate_random_theme
        theme_links               =   get_theme_links
        random_link               =   (theme_links && theme_links.any?) ? theme_links.to_a.sample : nil

        perform_activation(random_link["href"]) if (random_link)
      end
    
      def activate_theme(theme_identifier = 'twentytwelve')
        success                   =   false
        theme_links               =   get_theme_links
        
        if (theme_links && theme_links.any?)
          activation_link         =   nil
          regex                   =   Regexp.new("stylesheet=#{theme_identifier}", Regexp::IGNORECASE)
      
          theme_links.each do |link|
            href                  =   link["href"]
        
            if (regex.match(href))
              activation_link     =   href
              break
            end
          end
      
          success                 =   perform_activation(activation_link)
          
          if success
            puts "[WpWrapper::Modules::Themes] - #{Time.now}: Url: #{self.url}. Theme '#{theme_identifier}' has been activated!"
          else
            puts "[WpWrapper::Modules::Themes] - #{Time.now}: Url: #{self.url}. Couldn't find the theme #{theme_identifier}'s activation-link."
          end
        end
      
        return success
      end
      
      def perform_activation(url)
        success                 =   false
        
        if (url && url.present?)
          puts "[WpWrapper::Modules::Themes] - #{Time.now}: Will activate theme with url #{url}."
          self.mechanize_client.open_url(url)
          success               =   true
        end
        
        return success
      end
      
      def get_theme_links
        theme_links           =   []
        
        if (login)
          themes_page         =   self.mechanize_client.open_url(get_url(:themes))
          
          if (themes_page)
            theme_links       =   themes_page.parser.css("div.themes div.theme div.theme-actions a.activate")
          end
        end
        
        puts "[WpWrapper::Modules::Themes] - #{Time.now}: Found a total of #{theme_links.try(:size)} installed themes."
        
        return theme_links
      end

    end
  end
end