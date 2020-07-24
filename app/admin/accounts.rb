ActiveAdmin.register Account do
  permit_params :account_type_id, :email, :first_name, :last_name, :password, :password_confirmation
  form do |f|
    f.inputs do
      f.input :email
      f.input :account_type_id, label: 'Account type', as: :select, collection: AccountType.all
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
