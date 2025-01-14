module Checkout
  class RepositoryHooks < Redmine::Hook::ViewListener
    # Renders the checkout URL
    #
    # Context:
    # * :project => Current project
    # * :repository => Current Repository
    #
    def view_repositories_show_contextual(context={})
      return unless context[:repository].present? && (
        Setting.plugin_redmine_checkout["display_info"] == 'everywhere' || (
          Setting.plugin_redmine_checkout["display_info"] == 'browse' &&
          context[:request].params[:action] == 'show'
        )
      )

      protocols = context[:repository].checkout_protocols.select do |p|
        p.access_rw(User.current)
      end

      path = context[:controller].instance_variable_get("@path")
      default = protocols.find(&:default?) || protocols.first

      context.merge!({
        :protocols => protocols,
        :default_protocol => default,
        :checkout_path => path
      })

      options = {:partial => "redmine_checkout_hooks/view_repositories_show_contextual"}
      context[:hook_caller].send(:render, {:locals => context}.merge(options))
    end
    alias_method :view_repositories_list_contextual, :view_repositories_show_contextual
  end
end
