module SamplesHelper
  def samples_alert(message)
    ['all samples created.', 'samples created.', 'last iteration purged.'].include?(message) ? 'success' : 'danger'
  end
end
