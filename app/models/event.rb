# == Schema Information
#
# Table name: events
#
#  uuid              :uuid             not null
#  external_id       :string           not null
#  title             :string           not null
#  sell_mode         :string           not null
#  organizer_company_id :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Event < ApplicationRecord
end
