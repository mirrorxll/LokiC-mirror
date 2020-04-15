# frozen_string_literal: true

module DataSetsHelper # :nodoc:
  def domain_name(link, options = {})
    match = link[%r{https?:\/\/([^\/]+)}, 1]
    match ? link_to(match, link, options) : link
  end

  def src_keys
    [
      [:src_address, 'address'],
      [:src_explaining_data, 'explaining data'],
    ]
  end

  def data_set_keys
    [
      [:location, 'location'],
      [:evaluation_document, 'evaluation document']
    ]
  end

  def release_frequency(dst)
    if dst.src_release_frequency
      dst.src_release_frequency.name
    else
      dst.src_release_frequency_manual
    end
  end

  def scrape_frequency(dst)
    if dst.src_scrape_frequency
      dst.src_scrape_frequency.name
    else
      dst.src_scrape_frequency_manual
    end
  end

  def allow_evaluate?(data_set)
    data_set.evaluation_document.present? && !data_set.evaluated
  end

  def eval_doc(data_set)
    data_set.evaluation_document.present? ? data_set.evaluation_document : '---'
  end

  def eval_indicate(data_set)
    if data_set.evaluated?
      '(evaluated)'
    else
      '(not evaluated'\
      "#{data_set.evaluation_document.present? ? '' : ' - document is missing'}"\
      ')'
    end
  end
end
