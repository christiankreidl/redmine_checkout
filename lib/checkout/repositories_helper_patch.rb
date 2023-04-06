module Checkout
  module RepositoriesHelperPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        prepend InstanceMethods
      end
    end

    module InstanceMethods

      # add checkout setting to repository settings
      def repository_field_tags(form, repository)
        tags = super(form, repository) || ""
        return tags if repository.class.name == "Repository"

        tags << controller.render_to_string(:partial => 'projects/settings/repository_checkout', :locals => {:form => form, :repository => repository, :scm => repository.type.demodulize}).html_safe
      end

      def scm_select_tag(*args)
        heads_for_wiki_formatter
        content_for :header_tags do
          javascript_include_tag('subform', :plugin => 'redmine_checkout') +
          stylesheet_link_tag('checkout', :plugin => 'redmine_checkout')
        end
        super(*args)
      end
    end
  end
end

RepositoriesHelper.send(:include, Checkout::RepositoriesHelperPatch)

