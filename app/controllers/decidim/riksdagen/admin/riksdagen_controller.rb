# frozen_string_literal: true
module Decidim
  module Riksdagen
    module Admin
      # Controller that allows managing Export.
      #
      class RiksdagenController < Decidim::Admin::ApplicationController
        layout "decidim/admin/riksdagen"

        @representatives = nil

        RIKSDAGEN_BASE_URL = 'http://riksdagen.se'
        DATA_RIKSDAGEN_BASE_URL = 'http://data.riksdagen.se'
        REPRESENTATIVE_BASE_URL = RIKSDAGEN_BASE_URL + '/sv/ledamoter-partier/ledamot/'

        def index
          authorize! :index, Decidim::Riksdagen
          @representatives = get_representatives
        end

        def show
          authorize! :show, Decidim::Riksdagen
        end

        def import_representative
          authorize! :show, Decidim::Riksdagen
          representative = get_representatives.find {|rep| rep['intressent_id'] == params[:iid]}
          create_representative(representative)
        end

        def import_all
          authorize! :show, Decidim::Riksdagen
          get_representatives.each do |rep|
            create_representative(rep)
          end
        end

        def get_representative(iid = '')
          url = DATA_RIKSDAGEN_BASE_URL + "/personlista/?utformat=json&iid=#{iid}"
          data = JSON.parse(open(url).read)

          data['personlista']['person']
        end

        def get_representatives
          #file = File.read(File.expand_path("data.json", File.dirname(__FILE__) + '../../../../../../'))
          #data = JSON.parse(file)
          #data['personlista']['person']

          @representatives ||= get_representative
          @imported_rep = User.all.to_a

          @representatives.each do |rep|
            rep['already_imported'] =
            @imported_rep.any? { |i_rep| i_rep.invitation_token == rep['intressent_id'] }
          end
        end

        def create_representative(rep)
          first_name = rep['tilltalsnamn']
          last_name = rep['efternamn']
          nickname = "#{first_name}#{last_name}BOT".delete(' ')

          if nickname.length >= 20
            if last_name.include? ' '
              nickname = "#{first_name}#{last_name.partition(' ').first}BOT"
            elsif first_name.include? ' '
              nickname = "#{first_name.partition(' ').first}#{last_name}BOT"
            end
            if nickname.length >= 20
              nickname = "#{first_name}#{rep['efternamn']}".delete(' ')[0..16] + "BOT"
            end
          end

          require 'open-uri'

          avatar = Tempfile.new(["#{first_name}#{last_name}", ".jpg"])
          avatar.binmode
          avatar.write open(rep['bild_url_80']).read
          avatar.rewind

          representative = Decidim::User.find_or_initialize_by(invitation_token: rep['intressent_id'])
          representative.update!(
            name: "#{rep['tilltalsnamn']} #{rep['efternamn']} (BOT)",
            personal_url: "#{REPRESENTATIVE_BASE_URL}_#{rep['sourceid']}",
            nickname: nickname,
            avatar: avatar,
            officialized_as: {
              'en': 'Member of parliament',
              'sv': 'Riksdagsledamot'
            },
            officialized_at: DateTime.now,
            managed: true,
            about: create_about_text(rep),
            decidim_organization_id: 1,
            tos_agreement: true
          )
        end

        def create_about_text(rep)
            "Hej, jag är en bot som publicerar "\
            "allting #{rep['tilltalsnamn']} #{rep['efternamn']} "\
            "gör och säger i Riksdagen. "\
            "Den riktiga #{rep['tilltalsnamn']} är ledamot för valkretsen "\
            "#{rep['valkrets']} och partiet #{rep['parti']}."
        end
      end
    end
  end
end