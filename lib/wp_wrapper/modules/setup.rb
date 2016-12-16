module WpWrapper
  module Modules
    module Setup
    
      def setup(title: nil, email: nil)
        success           =   false
        step_1_page       =   self.mechanize_client.open_url(get_url(:home))
      
        if step_1_page
          step_1_form     =   step_1_page.form_with(action: '?step=1')

          if step_1_form
            step_2_page   =   step_1_form.submit
            success       =   set_setup_form_options(step_2_page, title: title, email: email)
          else
            success       =   set_setup_form_options(step_1_page, title: title, email: email)
          end
        end
      
        return success
      end
      
      def set_setup_form_options(setup_page, title: nil, email: nil)
        success       =   false
        setup_form    =   setup_page.form_with(action: 'install.php?step=2')

        if (setup_form && title.present? && self.username.present? && self.password.present? && email.present?)
          puts "#{Time.now}: Url: #{self.url}. Setting up site..."

          setup_form.field_with(name: 'weblog_title').value      =   title
          setup_form.field_with(name: 'user_name').value         =   self.username
          setup_form.field_with(name: 'admin_password').value    =   self.password
          setup_form.field_with(name: 'admin_password2').value   =   self.password
          setup_form.field_with(name: 'admin_email').value       =   email

          confirmation_page                                      =   setup_form.submit

          puts "[WpWrapper::Modules::Setup] - #{Time.now}: Url: #{self.url}. The WordPress-blog has now been installed!"
          success                                                =   true
        else
          puts "[WpWrapper::Modules::Setup] - #{Time.now}: Url: #{self.url}. The blog has already been setup or the registration form couldn't be found or some data is missing."
          puts "[WpWrapper::Modules::Setup] - #{Time.now}: Url: #{self.url}. Information supplied:\nTitle: #{title}.\nUsername: #{self.username}.\nPassword: #{self.password}.\nEmail: #{email}."
        end
        
        return success
      end
    
      def set_permalinks_options(options = {})
        permalink_structure       =     options.fetch(:permalink_structure, '/%postname%/')
        category_base             =     options.fetch(:category_base,       'kategori')
        tag_base                  =     options.fetch(:tag_base,            'etikett')
      
        opts                      =     {
          :custom_selection       =>  {:identifier => :id,              :checked => true,         :type => :radiobutton},
          :permalink_structure    =>  {:value => permalink_structure,   :type => :input},
          :category_base          =>  {:value => category_base,         :type => :input},
          :tag_base               =>  {:value => tag_base,              :type => :input},
        }
      
        return set_options_and_submit("options-permalink.php", {:action => 'options-permalink.php'}, opts, :first, {:should_reset_radio_buttons => true})
      end

    end
  end
end