require_dependency 'settings_helper'

module Checkout
  module SettingsHelperPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        prepend InstanceMethods
      end
    end
  
    module InstanceMethods
      def administration_settings_tabs
        tabs = super
        tabs << {:name => 'checkout', :partial => 'settings/checkout', :label => :label_checkout}
      end
    end
  end
end

SettingsHelper.send(:include, Checkout::SettingsHelperPatch)

