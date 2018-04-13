# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Riksdagen
    # This is the engine that runs on the public interface of riksdagen.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Riksdagen

      routes do
        # Add engine routes here
        # resources :riksdagen
        # root to: "riksdagen#index"
      end

      initializer "decidim_riksdagen.assets" do |app|
        app.config.assets.precompile += %w[decidim_riksdagen_manifest.js decidim_riksdagen_manifest.css]
      end

      initializer "decidim_riksdagen.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Riksdagen::Abilities::Admin::AdminAbility"]
        end
      end
    end
  end
end
