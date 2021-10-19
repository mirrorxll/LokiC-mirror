# frozen_string_literal: true

class TaskAssignment < ApplicationRecord # :nodoc:
  belongs_to :task
  belongs_to :account

  def name
    account.name
  end

  def time_confirm
    confirmed_at - created_at
  end

  # def dates
  #   created_at.to_date..updated_at.to_date
  # end
  #
  # def day_off?(date)
  #   date.sunday? || date.saturday?
  # end
  #
  # def saturdays
  #   saturdays = []
  #   updated_at.to_date - created_at.to_date).each { |date| saturdays << date.saturday? }
  # end
  #
end
