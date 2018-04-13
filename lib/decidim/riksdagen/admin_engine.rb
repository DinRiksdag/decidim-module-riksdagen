# frozen_string_literal: true

module Decidim
  module Riksdagen
    # This is the engine that runs on the public interface of `Riksdagen`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Riksdagen::Admin

      paths["db/migrate"] = nil

      initializer "decidim_admin_riksdagen.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Riksdagen::AdminEngine => "/admin/riksdagen"
        end
      end

      routes do
        get '', to: 'riksdagen#index'
        post 'import_representative', to: 'riksdagen#import_representative'
        post 'import_all', to: 'riksdagen#import_all'

        get 'bills', to: 'bills#index', as: :bills
        post 'import_bill', to: 'bills#import_bill'
        post 'import_all', to: 'bills#import_all'

        root to: "riksdagen#index"
      end

      initializer "decidim_riksdagen.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_riksdagen_manifest.js)
      end

      initializer "decidim_riksdagen.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += ["Decidim::Riksdagen::Abilities::Admin::AdminAbility"]
        end
      end

      initializer "decidim_riksdagen.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.riksdagen", scope: "decidim.admin"),
            decidim_riksdagen_admin.root_path,
            icon_name: "rss",
            position: 5.5,
            active: :inclusive,
            if: can?(:read, current_organization)
        end
      end
    end
  end
end
