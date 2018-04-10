# frozen_string_literal: true

module Decidim
  module Riksdagen
    # This is the engine that runs on the public interface of `Riksdagen`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Riksdagen::Admin

      paths["db/migrate"] = nil

      routes do
        # Add admin engine routes here
        # resources :riksdagen do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "riksdagen#index"
      end

      initializer "decidim_riksdagen.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += ["Decidim::Riksdagen::Abilities::Admin::AdminAbility"]
        end
      end

      def load_seed
        nil
      end
    end
  end
end
