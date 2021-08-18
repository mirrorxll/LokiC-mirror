# frozen_string_literal: true

class ArticleTypeIteration < ApplicationRecord
  serialize :sample_args, Hash

  after_create do
    if !name.eql?('Initial') && !article_type.status.name.in?(%w[canceled blocked])
      article_type.update!(status: Status.find_by(name: 'in progress'), current_account: current_account)
    end
  end

  belongs_to :article_type

  has_many :articles

  def show_samples
    samples.where(show: true)
  end
end
