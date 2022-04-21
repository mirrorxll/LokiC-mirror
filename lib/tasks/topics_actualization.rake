# frozen_string_literal: true

namespace :topics do
  desc 'Actualize internal topics with Limpar'
  task update_topics: :environment do
    TopicsJob.new.perform
  end
end
