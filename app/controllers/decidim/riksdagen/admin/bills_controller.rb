# frozen_string_literal: true
module Decidim
  module Riksdagen
    module Admin
      class BillsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/riksdagen"

        @bills = nil

        RIKSDAGEN_BASE_URL = 'http://riksdagen.se'
        DATA_RIKSDAGEN_BASE_URL = 'http://data.riksdagen.se'

        def index
          authorize! :index, Decidim::Riksdagen
          @bills = get_bills
        end

        def show
          authorize! :show, Decidim::Riksdagen
        end

        def import_bill
          authorize! :show, Decidim::Riksdagen

          bill = get_bill(params[:bill_id])
          create_bill(bill)
        end

        def import_all
          authorize! :show, Decidim::Riksdagen
          get_bills.each do |b|
            create_bill(b)
          end
        end

        def get_bill(id)
          bill = {}
          bill['prop'] = get_dokument(id)
          bill['prop_status'] = get_dokument_status(id)

          if bill['prop_status'].key?('dokreferens')
            decision_id = bill['prop_status']['dokreferens']['referens']
                              .find { |r| r['referenstyp'] == 'behandlas_i' }['ref_dok_id']
            bill['bet'] = get_dokument(decision_id)
            bill['bet_status'] = get_dokument_status(decision_id)
            bill['videostream'] = get_video_stream(decision_id)
          end

          bill
        end

        def get_bills
          if @bills == nil
            url = DATA_RIKSDAGEN_BASE_URL + "/dokumentlista/?doktyp=prop&sort=datum" +
                                            "&sortorder=desc&utformat=json#soktraff"
            data = JSON.parse(open(url).read)

            @bills = data['dokumentlista']['dokument']
          end

          @imported_bills = ParticipatoryProcess.where(decidim_participatory_process_group_id: 3)

          @bills.each do |bill|
            bill['already_imported'] =
            @imported_bills.any? { |i_bill| i_bill.slug == bill['id'] }
          end

          @bills
        end

        def get_dokument_status(id)
          doc_status_url = DATA_RIKSDAGEN_BASE_URL + "/dokumentstatus/#{id}.json"
          data = JSON.parse(open(doc_status_url).read)
          data['dokumentstatus']
        end

        def get_dokument(id)
          url = DATA_RIKSDAGEN_BASE_URL + "/dokumentlista/?sok=#{id}" +
                                          "&doktyp=prop&utformat=json#soktraff"
          data = JSON.parse(open(url).read)
          data['dokumentlista']['dokument'][0]
        end

        def get_video_stream(id)
          url = RIKSDAGEN_BASE_URL + "/api/videostream/get/#{id}"
          Hash.from_xml(open(url).read).to_json
        end

        def create_bill(bill)
          prop = bill['prop']
          prop_status = bill['prop_status']
          bet = bill['bet']
          bet_status = bill['bet_status']
          process = Decidim::ParticipatoryProcess.find_or_initialize_by(slug: prop['id'])
          process.update!(
            slug: prop['id'],
            title: {
              'sv': prop['titel']
            },
            subtitle: {
              'sv': prop['sokdata']['undertitel']
            },
            short_description: {
              'sv': prop['summary']
            },
            description: {
              'sv': prop['notis']
            },
            developer_group: {
              'sv': prop['organ']
            },
            decidim_organization_id: 1,
            decidim_participatory_process_group_id: 3,
            show_statistics: true
          )

          process_step = [
            get_locales_for('decidim.riksdagen.bill.step.proposal'),
            get_locales_for('decidim.riksdagen.bill.step.citizen_proposals'),
            get_locales_for('decidim.riksdagen.bill.step.commission'),
            get_locales_for('decidim.riksdagen.bill.step.debate'),
            get_locales_for('decidim.riksdagen.bill.step.vote')
          ]
          process_step_date = [
            'publicerad',
            'beredningsdag',
            'debattdag',
            'beslutsdag'
          ]

          index = 0
          process_step.each do |step|
            if !prop[process_step_date[index]].nil?
              start_date = Time.parse(prop[process_step_date[index]])
            end
            if !prop[process_step_date[index + 1]].nil?
              end_date = Time.parse(prop[process_step_date[index + 1]])
            end

            process_step = Decidim::ParticipatoryProcessStep.find_or_initialize_by(
              participatory_process: process,
              position: index
            )
            process_step.update!(
              title: step,
              description: "test",
              start_date: start_date,
              end_date: end_date
            )

            if index == 0
              process_step.update!(
                active: true
              )
            end
            index += 1
          end
        end

        def get_locales_for(key)
          JSON.parse({
            'sv': I18n.t(key, locale: :sv),
            'en': I18n.t(key, locale: :en)
          }.to_json)
        end
      end
    end
  end
end