# CSV.open("/home/app/st_types.csv", "wb") do |csv|
#   StoryType.all.each do |st|
#     puts st.id
#     samples = st.samples.where.not(pl_production_story_id: nil).order('RAND()').limit(3)
#     sample_1 = samples.first&.pl_link
#     sample_2 = samples.second&.pl_link
#     sample_3 = samples.third&.pl_link
#
#     csv << [st.name, sample_1, sample_2, sample_3]
#   end
# end

# CSV.open("/home/app/st_types.csv", "wb") do |csv|
#   StoryType.where("name RLIKE 'cancelled as countrywide'").each do |st|
#     puts st.id
#     sample = st.stories.limit(1).first
#     if sample
#       url = "https://lokic.locallabs.com#{Rails.application.routes.url_helpers.story_type_iteration_sample_path(sample.story_type, sample.iteration, sample)}"
#     end
#     csv << [st.id, st.data_set.name, st.name, url]
#   end
# end

# quarterly report for John
{ q3_2021: %w[2021-07-01 2021-09-30] }.each do |q, d|
  exports =
    Story.where("exported_at BETWEEN '#{d.first}' AND '#{d.last}'")
         .group(:story_type_iteration_id).order(:exported_at, :story_type_id, :story_type_iteration_id)

  CSV.open("/home/app/#{q}_all_exports.csv", "wb") do |csv|
    exports.each do |exp|
      iter = exp.iteration
      story_type = iter.story_type
      link = story_type.first_show_sample&.pl_link || iter.stories.exported.first&.pl_link

      csv << [
        iter.stories.exported.where.not(exported_at: nil).first.exported_at.to_date,
        story_type.name,
        link
      ]

      puts story_type.id
    end
  end

  puts '-----'

  CSV.open("/home/app/#{q}_init_exports.csv", "wb") do |csv|
    exports.each do |exp|
      next unless exp.story_type.iterations.first.eql?(exp.iteration)

      iter = exp.iteration
      story_type = iter.story_type
      link = story_type.first_show_sample&.pl_link || iter.stories.exported.first&.pl_link

      csv << [
        iter.stories.exported.where.not(exported_at: nil).first.exported_at.to_date,
        story_type.name,
        link
      ]

      puts story_type.id
    end
  end

  puts '-----'

  CSV.open("/home/app/#{q}_follow_up_exports.csv", "wb") do |csv|
    exports.each do |exp|
      next if exp.story_type.iterations.first.eql?(exp.iteration)

      iter = exp.iteration
      story_type = iter.story_type
      link = story_type.first_show_sample&.pl_link || iter.stories.exported.first&.pl_link

      csv << [
        iter.stories.exported.where.not(exported_at: nil).first.exported_at.to_date,
        story_type.name,
        link
      ]

      puts story_type.id
    end
  end
end
