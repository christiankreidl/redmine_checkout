module Checkout
  module RepositoryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        serialize :checkout_settings, Hash

        safe_attributes 'checkout_settings',
          'checkout_overwrite',
          'checkout_description',
          'checkout_protocols',
          'checkout_display_command'
      end
    end

    module ClassMethods
      def allow_subtree_checkout?
        # default implementation
        false
      end

      def checkout_default_command
        # default implementation
        ""
      end
    end

    module InstanceMethods
      def after_initialize
        self.checkout_settings ||= {}
      end

      def checkout_overwrite=(value)
        self.checkout_settings ||= {}
        checkout_settings['checkout_overwrite'] = value
      end

      def checkout_overwrite
        (checkout_settings['checkout_overwrite'].to_i > 0) ? '1' : '0'
      end

      def checkout_overwrite?
        self.type.present? && checkout_overwrite.to_i > 0
      end

      def checkout_description=(value)
        self.checkout_settings ||= {}
        checkout_settings['checkout_description'] = value
      end

      def checkout_description
        if checkout_overwrite?
          checkout_settings['checkout_description']
        else
          if type.present? && CheckoutHelper.supported_scm.include?(type.demodulize) && Setting.plugin_redmine_checkout["overwrite_description_#{type.demodulize}"].to_i > 0
            Setting.plugin_redmine_checkout["description_#{type.demodulize}"]
          else
            Setting.plugin_redmine_checkout["description_Abstract"]
          end
        end
      end

      def checkout_protocols
        @checkout_protocols ||= begin
          if type.present? && CheckoutHelper.supported_scm.include?(type.demodulize)
            if checkout_overwrite?
              protocols = checkout_settings['checkout_protocols'] || []
            else
              protocols = Setting.plugin_redmine_checkout["protocols_#{type.demodulize}"] || []
            end
          else
            protocols = []
          end

          protocols.collect do |p|
            Checkout::Protocol.new p.merge({:repository => self})
          end
        end
      end

      def checkout_protocols=(value)
        # value is an Array or a Hash
        if value.is_a? ActiveSupport::HashWithIndifferentAccess
          value = value.dup.delete_if {|id, protocol| id.to_i < 0 }
          value = value.values
        end
        self.checkout_settings ||= {}
        checkout_settings['checkout_protocols'] = value
      end

      def checkout_display_command?
        checkout_display_command.to_i > 0
      end

      def checkout_display_command=(value)
        self.checkout_settings ||= {}
        checkout_settings['checkout_display_command'] = value
      end

      def checkout_display_command
        if checkout_overwrite?
          checkout_settings['checkout_display_command']
        else
          Setting.plugin_redmine_checkout["display_command_#{type.demodulize}"]
        end
      end

      def allow_subtree_checkout?
        self.class.allow_subtree_checkout?
      end

      def checkout_default_command
        self.class.checkout_default_command
      end

      def to_xml(options = {}, &block)
        options[:except] = options[:except] ?
                            options[:except] << :checkout_settings :
                            [:checkout_settings]

        super
      end
    end
  end
end

Repository.send(:include, Checkout::RepositoryPatch)

subtree_checkout_repos = ["Subversion", "Cvs"]
commands = {
  'Bazaar' => 'bzr checkout',
  'Cvs' => 'cvs checkout',
  'Darcs' => 'darcs get',
  'Git' => 'git clone',
  'Mercurial' => 'hg clone',
  'Subversion' => 'svn checkout'
}

CheckoutHelper.supported_scm.each do |scm|
  require_dependency "repository/#{scm.underscore}"
  cls = Repository.const_get(scm)

  allow_subtree_checkout = ""
  if subtree_checkout_repos.include? scm
    allow_subtree_checkout = <<-EOS
     def allow_subtree_checkout?
        true
      end
    EOS
  end

  checkout_command = ""
  if commands[scm]
    checkout_command = <<-EOS
      def checkout_default_command
        '#{commands[scm]}'
      end
    EOS
  end

  class_mod = Module.new
  class_mod.module_eval(<<-EOF
    def self.included(base)
      base.extend ChildClassMethods

      base.class_eval do
        unloadable
        serialize :checkout_settings, Hash
      end
    end

    module ChildClassMethods
      #{allow_subtree_checkout}
      #{checkout_command}
    end
  EOF
  )
  cls.send(:include, class_mod)
end
