class LimparPeople < LimparRecord
  self.table_name = 'people'

  def name
    "#{first_name} #{middle_name.nil? ? '' : middle_name + ' ' }#{last_name}"
  end
end
