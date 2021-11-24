# frozen_string_literal: true

class TaskChecklistAssignment < ApplicationRecord # :nodoc:
  belongs_to :account
  belongs_to :checklist, class_name: 'TaskChecklist'
end
