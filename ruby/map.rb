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
      'D' => { 'H' => 90, 'C' => 200, 'E' => 80 },
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

    numbered_nodes = example_nodes.map.with_index.map { |(k, v), i| [i, k] }.to_h
    nodes_numbered = numbered_nodes.invert

    adjacency_matrix = Matrix.build(number_of_nodes) { Float::INFINITY }.to_a
    next_matrix = Matrix.build(number_of_nodes) { nil }.to_a

    filled_adjacency_matrix = adjacency_matrix.map.with_index do |row, row_i|
      row.map.with_index do |x, col_i|
        if row_i == col_i
          0
        else
          if example_nodes[numbered_nodes[row_i]].has_key?(numbered_nodes[col_i])
            example_nodes[numbered_nodes[row_i]][numbered_nodes[col_i]]
          else
            x
          end
        end
      end
    end

    filled_next_matrix = next_matrix.map.with_index do |row, row_i|
      row.map.with_index do |x, col_i|
        if example_nodes[numbered_nodes[row_i]].has_key?(numbered_nodes[col_i])
          numbered_nodes[col_i]
        else
          x
        end
      end
    end

    number_of_nodes.times do |k|
      number_of_nodes.times do |i|
        number_of_nodes.times do |j|
          alternate = filled_adjacency_matrix[i][k] + filled_adjacency_matrix[k][j]
          if filled_adjacency_matrix[i][j] > alternate
            filled_adjacency_matrix[i][j] = alternate

            filled_next_matrix[i][j] = filled_next_matrix[i][k]
          end
        end
      end
    end
  end
end

map = Map.new
map.floyd_warshall
