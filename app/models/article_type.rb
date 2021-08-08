# frozen_string_literal: true

class ArticleType < ApplicationRecord
  after_create do
    create_template
    create_fact_checking_doc
    create_cron_tab
    create_reminder

    data_set.client_publication_tags.each do |client_publication_tag|
      clients_publications_tags.create!(
        client: client_publication_tag.client,
        publication: client_publication_tag.publication,
        tag: client_publication_tag.tag
      )
    end

    record_to_change_history(self, 'created', name, editor)

    iter = iterations.create!(name: 'Initial', current_account: current_account)
    update(current_iteration: iter)
  end

  before_update :tracking_changes

  validates_uniqueness_of :name, case_sensitive: true

  belongs_to :data_set,          counter_cache: true
  belongs_to :editor,            class_name: 'Account'
  belongs_to :developer,         optional: true, class_name: 'Account'
  belongs_to :frequency,         optional: true
  belongs_to :photo_bucket,      optional: true
  belongs_to :current_iteration, optional: true, class_name: 'Iteration'
  belongs_to :status,            optional: true

  has_one :staging_table
  has_one :template
  has_one :fact_checking_doc
  has_one :cron_tab
  has_one :reminder

  has_one_attached :code

  has_many :iterations
  has_many :export_configurations
  has_many :configurations_no_tags, -> { where(tag: nil).or(where(skipped: true)) }, class_name: 'ExportConfiguration'
  has_many :samples
  has_many :clients_publications_tags, class_name: 'StoryTypeClientPublicationTag'
  has_many :clients, through: :clients_publications_tags
  has_many :tags, through: :clients_publications_tags
  has_many :change_history, as: :history
  has_many :alerts, as: :alert

  def number_name
    "##{id} #{name}"
  end

  def developer_fc_channel_name
    developer&.fc_channel&.name
  end

  def iteration
    current_iteration
  end

  def download_code_from_db
    MiniLokiC::Code[self].download
  end

  def client_pl_ids
    clients_publications_tags.flat_map do |cl_p_t|
      if cl_p_t.client.name.eql?('Metric Media')
        Client.where('name LIKE :like', like: 'MM -%').map(&:pl_identifier)
      else
        cl_p_t.client.pl_identifier
      end
    end
  end

  def publication_pl_ids
    pubs = clients_publications_tags.flat_map do |cl_p_t|
      cl = cl_p_t.client

      cl_pubs =
        case cl_p_t.publication&.name
        when 'all local publications'
          cl.publications.where(statewide: false)
        when 'all statewide publications'
          cl.publications.where(statewide: true)
        when 'all publications', nil
          cl.publications
        else
          [cl_p_t.publication]
        end

      cl_pubs.map(&:pl_identifier)
    end

    pubs.uniq
  end

  def show_samples
    samples.where(show: true)
  end

  def first_show_sample
    smpls = show_samples.reverse
    smpls.count.positive? ? smpls.first : nil
  end

  def second_show_sample
    smpls = show_samples.reverse
    smpls.count > 1 ? smpls.second : nil
  end

  def third_show_sample
    smpls = show_samples.reverse
    smpls.count > 2 ? smpls.last : nil
  end

  def reminder_off?
    return false unless reminder&.turn_off_until

    reminder.turn_off_until > Date.today
  end

  def reminder_on?
    !reminder_off?
  end

  def updates?
    reminder&.has_updates
  end

  def updates_confirmed?
    reminder&.updates_confirmed
  end

  private

  def tracking_changes
    changes = {}
    changes['renamed'] = "#{name_change.first} -> #{name}" if name_changed?

    if developer_id_changed?
      old_developer = Account.find_by(id: developer_id_change.first)

      old_developer_name = old_developer&.name || 'not distributed'
      new_developer_name = developer&.name || 'not distributed'
      changes['distributed'] = "#{old_developer_name} -> #{new_developer_name}"

      SlackStoryTypeNotificationJob.perform_later(iteration, 'developer', 'Unpinned', old_developer) if old_developer
      SlackStoryTypeNotificationJob.perform_later(iteration, 'developer', 'Distributed to you', developer) if developer
    end

    if data_set_id_changed?
      old_data_set_name = DataSet.find_by(id: data_set_id_change.first)&.name || 'not selected'
      new_data_set_name = data_set&.name || 'not selected'
      changes['data set changed'] = "#{old_data_set_name} -> #{new_data_set_name}"
    end

    if frequency_id_changed?
      old_frequency_name = Frequency.find_by(id: frequency_id_change.first)&.name || 'not selected'
      new_frequency_name = frequency&.name || 'not selected'
      changes['frequency changed'] = "#{old_frequency_name} -> #{new_frequency_name}"
    end

    if photo_bucket_id_changed?
      old_photo_bucked_name = PhotoBucket.find_by(id: photo_bucket_id_change.first)&.name || 'not selected'
      new_photo_bucked_name = photo_bucket&.name || 'not selected'
      changes['photo bucked changed'] = "#{old_photo_bucked_name} -> #{new_photo_bucked_name}"
    end

    if current_iteration_id_changed? && !current_iteration_id_change.first.nil?
      old_iteration = Iteration.find_by(id: current_iteration_id_change.first)
      new_iteration = iteration

      old_iteration_id_name = "#{old_iteration.id}|#{old_iteration.name}"
      new_iteration_id_name = "#{new_iteration.id}|#{new_iteration.name}"
      changes['iteration changed'] = "#{old_iteration_id_name} -> #{new_iteration_id_name}"
    end

    if status_id_changed?
      old_status = Status.find_by(id: status_id_change.first).name
      new_status = status.name.in?(%w[blocked canceled]) ? "#{status.name}: #{status_comment&.body}" : status.name
      changes['progress status changed'] = "#{old_status} -> #{new_status}"
    end

    changes.each { |ev, ch| record_to_change_history(self, ev, ch, current_account) }
  end
end
