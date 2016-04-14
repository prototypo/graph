require 'matrix'
require 'awesome_print'
require 'pry'

# A - 100 - B - 300 - F - 50 - E - 30 - H
# |                   |        |\      /|
# |                   |       150\   50 |
# |                   |        |  \  /  |
# 30                  |        |   \/  90
# |                   |        |   /\   |
# |                   |        |  /  80 |
# |                   \        | /    \ |
# |                    \- 70 - G       \|
# C -------------- 200 ---------------- D

class Map
  def example_nodes
    {
      'A' => { 'B' => 100, 'C' => 30 },
      'B' => { 'A' => 100, 'F' => 300 },
      'F' => { 'B' => 300, 'E' => 50, 'G' => 70 },
      'E' => { 'F' => 50, 'H' => 30, 'G' => 150, 'D' => 80 },
      'G' => { 'F' => 70, 'E' => 150, 'H' => 50 },
      'H' => { 'E' => 30, 'G' => 50, 'D' => 90 },
      'D' => { 'H' => 90, 'C' => 200 },
      'C' => { 'D' => 200, 'A' => 30 }
    }

    # {
    #   'A' => { 'B' => 100, 'C' => 30 },
    #   'B' => { 'F' => 300 },
    #   'F' => { 'E' => 50, 'G' => 70 },
    #   'E' => { 'H' => 30, 'G' => 150, 'D' => 80 },
    #   'G' => { 'H' => 50 },
    #   'H' => { 'D' => 90 },
    #   'D' => {  },
    #   'C' => { 'D' => 200 }
    # }
  end

  def floyd_warshall
    # https://en.wikipedia.org/wiki/Floyd–Warshall_algorithm

    number_of_nodes = example_nodes.keys.size

    numbered_nodes = example_nodes.map.with_index.map { |(k,v), i| [k, i] }.to_h

    adjacency_matrix = Matrix.build(number_of_nodes) { Float::INFINITY }.to_a

    example_nodes.each do |k, v|
      i = numbered_nodes[k]
      adjacency_matrix[i][i] = 0

      example_nodes[k].each do |n, n2|
        adjacency_matrix[i][numbered_nodes[n]] = n2
      end
    end

    number_of_nodes.times do |k|
      number_of_nodes.times do |i|
        number_of_nodes.times do |j|
          alternate = adjacency_matrix[i][k] + adjacency_matrix[k][j]
          if adjacency_matrix[i][j] > alternate
            adjacency_matrix[i][j] = alternate
          end
        end
      end
    end
  end
end

map = Map.new
map.floyd_warshall
