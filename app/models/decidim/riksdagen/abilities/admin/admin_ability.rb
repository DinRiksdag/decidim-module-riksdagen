# frozen_string_literal: true

module Decidim
  module Riksdagen
    module Abilities
      module Admin
        # Defines the abilities related to riksdagen for a logged in admin user.
        # Intended to be used with `cancancan`.
        class AdminAbility < Decidim::Abilities::AdminAbility
          def define_abilities
            can :manage, Riksdagen
          end
        end
      end
    end
  end
end
