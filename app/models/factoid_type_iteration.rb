# frozen_string_literal: true

class FactoidTypeIteration < ApplicationRecord
  serialize :sample_args, Hash

  after_create do
    if !name.eql?('Initial') && !factoid_type.status.name.in?(['canceled', 'blocked', 'on cron'])
      factoid_type.update!(status: Status.find_by(name: 'in progress'), current_account: current_account)
    end
  end

  belongs_to :factoid_type

  has_one :published, dependent: :destroy, class_name: 'PublishedFactoid', foreign_key: :iteration_id

  has_many :articles

  def show_samples
    articles.where(show: true)
  end
end
