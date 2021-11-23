class UpdateSettings < ActiveRecord::Migration
  def self.up
    settings = Setting.plugin_redmine_checkout
    unless settings.class == Hash
      settings = {}
    end

    if settings.has_key? "use_zero_clipboard"
      settings.delete("checkout_url_regex")
    end
    
    Setting.plugin_redmine_checkout = settings
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new "Sorry, there is no down migration yet. If you really need one, please create an issue on http://dev.holgerjust.de/projects/redmine-checkout"
  end
end

