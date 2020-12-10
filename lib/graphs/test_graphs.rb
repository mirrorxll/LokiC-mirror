# see result here: https://jsfiddle.net/r1pvmqz0/
def bar_horizontal_test
  x_axis = %w(12/28/2019 01/04/2020 01/11/2020 01/18/2020 01/25/2020 02/01/2020 02/08/2020 02/15/2020 02/22/2020 02/29/2020)

  options = {
      width: 600,
      height: 400,
      font_size: 9,
      stack: :side, # the stack option is valid for Bar graphs only
      fields: x_axis,
      graph_title: "Test results for the past 10 weeks",
      show_graph_title: true,

      show_x_title: true,
      x_title: 'Positive Test Results',
      x_title_font_size: 10,
      x_title_location: :middle,

      x_label_font_size: 10,
      show_x_labels: false,
      step_include_first_x_label: true,
      rotate_x_labels: true,
      show_x_guidelines: false,

      show_y_title: false,
      y_title: 'Week ending',
      y_title_font_size: 10,
      y_title_location: :middle,

      show_y_labels: true,
      rotate_y_labels: false,
      scale_integers: true,
      show_y_guidelines: false,

      key: false,
      no_css: false,
      number_format: '%s' #'%.2sk'
  }

  total_positives = [20191, 18112, 16591, 18791, 21488, 25532, 25203, 23356, 20885, 17799]

  g = SVG::Graph::BarHorizontal.new(options)

  g.add_data( {
                  data: total_positives,
                  title: "Total Positives"
              })
  g.burn_svg_only
end

# see result here: https://jsfiddle.net/j4k2twL8/1/
def bar_horizontal_test_2_rows
  x_axis = %w(12/28/2019 01/04/2020 01/11/2020 01/18/2020 01/25/2020 02/01/2020 02/08/2020 02/15/2020 02/22/2020 02/29/2020)

  options = {
      width: 600,
      height: 400,
      font_size: 9,
      stack: :side, # the stack option is valid for Bar graphs only
      fields: x_axis,
      graph_title: "Test results for the past 10 weeks",
      show_graph_title: true,

      show_x_title: false,
      x_title: 'Positive Test Results',
      x_title_font_size: 10,
      x_title_location: :middle,

      x_label_font_size: 10,
      show_x_labels: false,
      step_include_first_x_label: true,
      rotate_x_labels: true,
      show_x_guidelines: false,

      show_y_title: false,
      y_title: 'Week ending',
      y_title_font_size: 10,
      y_title_location: :middle,

      show_y_labels: true,
      rotate_y_labels: false,
      scale_integers: true,
      show_y_guidelines: false,

      key: true,
      key_position: :bottom,
      add_popups: false,
      no_css: false,
      number_format: '%s' #'%.2sk'
  }

  total_tested = [67944, 69045, 64586, 64802, 69300, 77771, 76454, 72997, 68194, 64205]
  total_positives = [20191, 18112, 16591, 18791, 21488, 25532, 25203, 23356, 20885, 17799]

  g = SVG::Graph::BarHorizontal.new(options)

  g.add_data( {
                  data: total_tested,
                  title: "Total Tested"
              })
  g.add_data( {
                  data: total_positives,
                  title: "Total Positives"
              })
  g.burn_svg_only
end

# see result here: https://jsfiddle.net/dvb6r92m/
def bar_test
  x_axis = %w(12/28/2019 01/04/2020 01/11/2020 01/18/2020 01/25/2020 02/01/2020 02/08/2020 02/15/2020 02/22/2020 02/29/2020)

  options = {
      width: 600,
      height: 400,
      font_size: 9,
      stack: :side, # the stack option is valid for Bar graphs only
      fields: x_axis,
      graph_title: "Test results for the past 10 weeks",
      show_graph_title: true,
      x_label_font_size: 10,
      show_x_title: false,
      step_include_first_x_label: true,
      x_title: 'Week ending',
      x_title_font_size: 10,
      x_title_location: :middle,
      rotate_x_labels: true,
      show_y_title: true,
      scale_integers: true,
      y_title: 'Positive Test Results',
      y_title_font_size: 10,
      show_y_labels: false,
      rotate_y_labels: false,
      y_title_location: :middle,
      show_y_guidelines: false,
      key: false,
      no_css: false,
      number_format: '%s' #'%.2sk'
  }

  total_positives = [20191, 18112, 16591, 18791, 21488, 25532, 25203, 23356, 20885, 17799]

  g = SVG::Graph::Bar.new(options)

  g.add_data( {
                  data: total_positives,
                  title: "Total Positives"
              })
  g.burn_svg_only
end

# see result here: https://jsfiddle.net/p894jrL2/1/
def pie_test
  fields = ['do not meet std', 'partially meet std', 'meet std', 'exceed std']

  options = {
      width: 600,
      height: 400,
      graph_title: "Tsehootsooi Middle School AIMS results",
      show_graph_title: true,
      key: true,
      key_position: :bottom, #:bottom, # or :right
      fields: fields,

      show_shadow: false,
      shadow_offset: 10,
      show_data_labels: true,
      show_actual_values: false,
      show_percent: true,
      show_key_data_labels: true,
      show_key_actual_values: false,
      show_key_percent: false,
      expanded: false,
      expand_greatest: false,
      expand_gap: 10,
      show_x_labels: false,
      show_y_labels: false,
      datapoint_font_size: 10,

      font_size: 10,
      no_css: false,
      number_format: '%s' #'%.2sk'
  }

  g = SVG::Graph::Pie.new(options)

  data = [49, 22, 20, 8]

  g.add_data( {
                  data: data,
                  title: 'Percentages'
              })
  g.burn_svg_only
end

# see result here: https://jsfiddle.net/syn9cm3g/
def line_test
  x_axis = %w(12/28/2019 01/04/2020 01/11/2020 01/18/2020 01/25/2020 02/01/2020 02/08/2020 02/15/2020 02/22/2020 02/29/2020)

  options = {
      width: 600,
      height: 400,
      font_size: 9,
      fields: x_axis,
      graph_title: "Test results for the past 10 weeks",
      show_graph_title: true,

      show_x_title: false,
      x_title: 'Week ending',
      x_title_font_size: 10,
      x_title_location: :middle,

      x_label_font_size: 10,
      step_include_first_x_label: true,
      rotate_x_labels: false,
      stagger_x_labels: true,

      show_y_title: false,
      y_title: 'Positive Test Results',
      y_title_font_size: 10,

      min_scale_value: 0,
      scale_integers: true,
      show_y_labels: false,
      rotate_y_labels: false,
      y_title_location: :middle,
      show_y_guidelines: false,

      key: true,
      key_position: :bottom,
      no_css: false,
      number_format: '%s' #'%.2sk'
  }

  g = SVG::Graph::Line.new(options)

  total_tested = [67944, 69045, 64586, 64802, 69300, 77771, 76454, 72997, 68194, 64205]
  total_positives = [20191, 18112, 16591, 18791, 21488, 25532, 25203, 23356, 20885, 17799]

  g.add_data( {
                  data: total_tested,
                  title: "Total Tested"
              })
  g.add_data( {
                  data: total_positives,
                  title: "Total Positives"
              })
  g.burn_svg_only
end

# see result here: https://jsfiddle.net/1yzwtca4/
def timeser_test

  total_tested = ['12/28/2019', 67944, '01/04/2020', 69045, '01/11/2020', 64586, '01/18/2020', 64802, '01/25/2020', 69300, '02/01/2020', 77771, '02/08/2020', 76454, '02/15/2020', 72997, '02/22/2020', 68194, '02/29/2020', 64205]
  total_positives = ['12/28/2019', 20191, '01/04/2020', 18112, '01/11/2020', 16591, '01/18/2020', 18791, '01/25/2020', 21488, '02/01/2020', 25532, '02/08/2020', 25203, '02/15/2020', 23356, '02/22/2020', 20885, '02/29/2020', 17799]

  options = {
      width: 600,
      height: 400,
      font_size: 9,
      graph_title: "Test results for the past 10 weeks",
      show_graph_title: true,

      show_x_title: false,
      x_title: 'Week ending',
      x_title_font_size: 10,
      x_title_location: :middle,

      x_label_font_size: 10,
      step_include_first_x_label: true,
      rotate_x_labels: false,
      stagger_x_labels: true,
      x_label_format: '%m/%d/%y',

      min_x_value: DateTime.strptime('12/21/2019', '%m/%d/%Y').to_time,
      max_x_value: DateTime.strptime('03/07/2020', '%m/%d/%Y').to_time,
      timescale_divisions: '1 weeks',

      show_y_title: false,
      y_title: 'Positive Test Results',
      y_title_font_size: 10,

      min_scale_value: 0,
      scale_integers: true,
      show_y_labels: false,
      rotate_y_labels: false,
      y_title_location: :middle,
      show_y_guidelines: false,

      min_y_value: 0,
      max_y_value: 80000,

      key: true,
      key_position: :bottom,
      no_css: false,
      number_format: '%s' #'%.2sk'
  }

  g = SVG::Graph::TimeSeries.new(options)

  g.add_data( {
                  data: total_tested,
                  title: "Total Tested",
                  template: '%m/%d/%Y'
              })
  g.add_data( {
                  data: total_positives,
                  title: "Total Positives",
                  template: '%m/%d/%Y'
              })
  g.burn_svg_only
end
