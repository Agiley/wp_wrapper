module WpWrapper
  module Modules
    module Themes
      
      def activate_random_theme(ignore_themes: [])
        theme_links               =   get_theme_links(ignore_themes: ignore_themes)
        random_url                =   (theme_links && theme_links.any?) ? theme_links.sample : nil

        perform_activation(random_url) if random_url
      end
    
      def activate_theme(theme_identifier = 'twentytwelve')
        success                   =   false
        theme_links               =   get_theme_links
        
        if theme_links && theme_links.any?
          activation_link         =   nil
          regex                   =   Regexp.new("stylesheet=#{theme_identifier}", Regexp::IGNORECASE)
      
          theme_links.each do |link|
            href                  =   link["href"]
        
            if regex.match(href)
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
        success             =   false
        
        if url && url.present?
          puts "[WpWrapper::Modules::Themes] - #{Time.now}: Will activate theme with url #{url}."
          self.mechanize_client.open_url(url)
          success           =   true
        end
        
        return success
      end
      
      def get_theme_links(ignore_themes: [])
        theme_links         =   []
        
        if login
          themes_page       =   self.mechanize_client.open_url(get_url(:themes))
          links             =   themes_page ? themes_page.parser.css("div.themes div.theme div.theme-actions a.activate") : []
          
          links.each do |link|
            href            =   link["href"]
            
            if ignore_themes && ignore_themes.any?
              ignore_themes.each do |ignore_theme|
                regex       =   ignore_theme.is_a?(Regexp) ? ignore_theme : Regexp.new("stylesheet=#{ignore_theme}", Regexp::IGNORECASE)
          
                if !regex.match(href)
                  theme_links << href
                  break
                end
              end
            else
              theme_links << href
            end
          end if links && links.any?
        end
        
        puts "[WpWrapper::Modules::Themes] - #{Time.now}: Found a total of #{theme_links.size} theme activation links."
        
        return theme_links
      end

    end
  end
end
