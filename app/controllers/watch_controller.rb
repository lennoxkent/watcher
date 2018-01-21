class WatchController < ApplicationController


  def index
    graph

  end

  def graph(width=1000)
    graph = Gruff::Line.new(width) # the width of the resulting image
    graph.title = "Dataset"
    graph.hide_lines = true
    # graph.theme_odeo # available: theme_rails_keynote, theme_37signals, theme_odeo, or custom (fragile)
    graph.theme = {
        :colors => ['#3B5998'],
        :marker_color => 'silver',
        :font_color => '#333333',
        :background_colors => ['white', 'silver']
    }
    datapoints = 10.times.map{ Random.rand(11) }
    graph.data("data", datapoints)

    graph.write('output.png')
  end

end
