ActiveAdmin.register StoryType do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :editor_id, :developer_id, :data_set_id, :status_id, :frequency_id, :photo_bucket_id, :tag_id, :name, :last_export
  #
  # or
  #
  # permit_params do
  #   permitted = [:editor_id, :developer_id, :data_set_id, :status_id, :frequency_id, :photo_bucket_id, :tag_id, :name, :last_export]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
