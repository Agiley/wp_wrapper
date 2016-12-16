module WpWrapper
  module Modules
    module Authorization
    
      def login(retries = 3)
        success                 =   logged_in?
      
        if !logged_in?
          login_page            =   self.mechanize_client.open_url(get_url(:admin))
          agent                 =   self.mechanize_client.agent

          if login_page
            upgraded            =   upgrade_if_necessary(login_page)
            login(retries) if upgraded
            
            login_form          =   login_page.form_with(name: 'loginform')

            if login_form
              login_form.field_with(name: 'log').value = self.username
              login_form.field_with(name: 'pwd').value = self.password

              begin
                logged_in_page  =   login_form.submit
                log_out_link    =   logged_in_page.link_with(href: /wp-login\.php\?action=logout/i)
                self.logged_in  =   !log_out_link.nil?
                success         =   self.logged_in
              
                puts "[WpWrapper::Modules::Authorization] - #{Time.now}: Url: #{self.url}. Successfully logged in? #{self.logged_in}"
              
              rescue Exception => e
                puts "[WpWrapper::Modules::Authorization] - #{Time.now}: Url: #{self.url}. Failed to login. Error Class: #{e.class.name}. Error Message: #{e.message}"
                login(retries - 1) if retries > 0
                raise WpWrapper::FailedLoginException, "Failed to login" if retries <= 0 && self.reraise_exceptions
              end

            else
              puts "[WpWrapper::Modules::Authorization] - #{Time.now}: Url: #{self.url}. Something's broken! Can't find wp-admin login form! Retrying...\n\n"
              login(retries - 1) if retries > 0
              raise WpWrapper::FailedLoginException, "Failed to login" if retries <= 0 && self.reraise_exceptions
            end
          end
        end
      
        return success
      end
      
      def upgrade_if_necessary(page)
        upgraded        =   false
        upgrade_link    =   page.link_with(href: /upgrade\.php/i)
        
        if upgrade_link
          upgrade_link.click
          upgraded      =   true
        end
        
        return upgraded
      end

    end
  end
end
