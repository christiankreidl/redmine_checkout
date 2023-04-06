module Checkout
  module SettingsControllerPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        prepend InstanceMethods
        unloadable
      end
    end
    
    module InstanceMethods
      # when saving plugin settings:
      def plugin
        if request.post? && params['id'] == 'redmine_checkout'
          if params['settings'] && params['settings'].is_a?(ActionController::Parameters)
            settings = HashWithIndifferentAccess.new
            (params['settings'] || {}).each do |name, value|
                case value
                when Array
                  # remove blank values in array settings
                  value.delete_if {|v| v.blank? }
                when ActionController::Parameters
                  # change protocols hash to array.
                  value = value.values() if name.start_with? "protocols_"
                end
                settings[name.to_sym] = value
              end
            end
                        
            Setting.plugin_redmine_checkout = settings
            params[:settings] = settings
          end
        super
      end
    end
  end
end

SettingsController.send(:include, Checkout::SettingsControllerPatch)
