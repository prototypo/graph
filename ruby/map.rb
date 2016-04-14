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

    adjacency_matrix = adjacency_matrix(example_nodes)
    next_matrix = next_matrix(example_nodes)

    number_of_nodes = example_nodes.keys.size

    number_of_nodes.times do |k|
      number_of_nodes.times do |i|
        number_of_nodes.times do |j|
          alternate = adjacency_matrix[i][k] + adjacency_matrix[k][j]
          if adjacency_matrix[i][j] > alternate
            adjacency_matrix[i][j] = alternate

            next_matrix[i][j] = next_matrix[i][k]
          end
        end
      end
    end

    shortest_path('A', 'E', example_nodes, next_matrix)
  end

  def shortest_path(start, finish, nodes, next_matrix, path = [])
    nodes_numbered = nodes_numbered(nodes)

    numbered_start = nodes_numbered[start]
    numbered_finish = nodes_numbered[finish]

    if !next_matrix[numbered_start][numbered_finish]
      return path + [finish]
    else
      return shortest_path(
        next_matrix[nodes_numbered[start]][numbered_finish],
        finish,
        nodes,
        next_matrix,
        path + [start])
    end

    return path
  end

  def adjacency_matrix(nodes)
    adjacency_matrix = Matrix.build(nodes.keys.size) { Float::INFINITY }.to_a
    numbered_nodes = numbered_nodes(nodes)

    adjacency_matrix.map.with_index do |row, row_i|
      row.map.with_index do |x, col_i|
        if row_i == col_i
          0
        else
          if nodes[numbered_nodes[row_i]].has_key?(numbered_nodes[col_i])
            nodes[numbered_nodes[row_i]][numbered_nodes[col_i]]
          else
            x
          end
        end
      end
    end
  end

  def next_matrix(nodes)
    next_matrix = Matrix.build(nodes.keys.size) { nil }.to_a
    numbered_nodes = numbered_nodes(nodes)

    next_matrix.map.with_index do |row, row_i|
      row.map.with_index do |x, col_i|
        if nodes[numbered_nodes[row_i]].has_key?(numbered_nodes[col_i])
          numbered_nodes[col_i]
        else
          x
        end
      end
    end
  end

  def numbered_nodes(nodes)
    nodes.map.with_index.map { |(k, v), i| [i, k] }.to_h
  end

  def nodes_numbered(nodes)
    numbered_nodes(nodes).invert
  end
end

map = Map.new
ap map.floyd_warshall
