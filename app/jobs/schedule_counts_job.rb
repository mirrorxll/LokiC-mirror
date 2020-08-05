

hash = {}
StoryType.last.iteration.samples.select("publication_id, count(publication_id) count").group('publication_id').group_by { |el| el.client_name }.each { |k,v| hash[k] =  v.max_by{|el| el.count }.c ount }