# frozen_string_literal: true

class FactoidRequest < ApplicationRecord
  before_create do
    self.status = Status.find_by(name: 'not started')

    build_status_comment(subtype: 'status comment')
    build_description(subtype: 'description')
    build_purpose(subtype: 'purpose')

    (1..5).each do |n|
      public_send("build_template_#{n}_body", subtype: "template #{n} body")
      public_send("build_template_#{n}_assoc", subtype: "template #{n} assoc")
    end
  end

  belongs_to :requester, optional: true, class_name: 'Account'
  belongs_to :frequency, optional: true
  belongs_to :agency, optional: true
  belongs_to :opportunity, optional: true
  belongs_to :opportunity_type, optional: true
  belongs_to :revenue_type, optional: true
  belongs_to :priority, optional: true
  belongs_to :status, optional: true

  has_one :status_comment, -> { where(subtype: 'status comment') }, as: :commentable, class_name: 'Comment'
  has_one :description, -> { where(subtype: 'description') }, as: :commentable, class_name: 'Comment'
  has_one :purpose, -> { where(subtype: 'purpose') }, as: :commentable, class_name: 'Comment'
  has_one :template_1_body, -> { where(subtype: 'template 1 body') }, as: :commentable, class_name: 'Comment'
  has_one :template_2_body, -> { where(subtype: 'template 2 body') }, as: :commentable, class_name: 'Comment'
  has_one :template_3_body, -> { where(subtype: 'template 3 body') }, as: :commentable, class_name: 'Comment'
  has_one :template_4_body, -> { where(subtype: 'template 4 body') }, as: :commentable, class_name: 'Comment'
  has_one :template_5_body, -> { where(subtype: 'template 5 body') }, as: :commentable, class_name: 'Comment'

  has_one :template_1_assoc, -> { where(subtype: 'template 1 assoc') }, as: :commentable, class_name: 'Comment'
  has_one :template_2_assoc, -> { where(subtype: 'template 2 assoc') }, as: :commentable, class_name: 'Comment'
  has_one :template_3_assoc, -> { where(subtype: 'template 3 assoc') }, as: :commentable, class_name: 'Comment'
  has_one :template_4_assoc, -> { where(subtype: 'template 4 assoc') }, as: :commentable, class_name: 'Comment'
  has_one :template_5_assoc, -> { where(subtype: 'template 5 assoc') }, as: :commentable, class_name: 'Comment'

  has_and_belongs_to_many :data_sets

  def template_association_1
    template_associations.find_by(num: 1)
  end

  def template_association_2
    template_associations.find_by(num: 2)
  end

  def template_association_3
    template_associations.find_by(num: 3)
  end

  def template_association_4
    template_associations.find_by(num: 4)
  end

  def template_association_5
    template_associations.find_by(num: 5)
  end
end
