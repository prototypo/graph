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

class Graph
  attr_accessor :nodes

  def load_nodes(nodes, merge = false)
    if merge
      if nodes.values.first == nil
        # Deleting nodes
        @nodes = @nodes.select { |k, v| k != nodes.keys.first }
        @nodes = @nodes.map { |k, v| [k, v.select { |sk, sv| sk != nodes.keys.first }] }.to_h

      elsif nodes.select { |k, v| v.values.any? { |x| x == nil } }.size > 0
        # Deleting paths
        @nodes = @nodes.map { |k, v| [k, v.reject { |sk, sv| sk == nodes.keys.first || sk == nodes.values.first.keys.first }] }.to_h
      else
        # Modifying paths
        @nodes = @nodes.merge(mirror_paths(nodes)) { |k, old_nodes, new_nodes| old_nodes.merge(new_nodes) }
      end
    else
      # Fresh loading nodes and paths
      @nodes = mirror_paths(normalise_nodes(nodes))
    end
  end

  # https://en.wikipedia.org/wiki/Floyd–Warshall_algorithm
  def floyd_warshall(nodes, i, j)
    if i == j
      return 0
    end

    if i == j - 1
      return nodes[i][j]
    end

    return ((i + 1)...j).reduce(Float::INFINITY) do |max, k|
      x = [nodes[i][j], floyd_warshall(nodes, i, k) + floyd_warshall(nodes, k, j)].min

      x < max ? x : max
    end
  end

  def self.example_nodes
    [
      { 'A' => { 'B' => 100, 'C' => 30 } },
      { 'B' => { 'F' => 300 } },
      { 'F' => { 'E' => 50, 'G' => 70 } },
      { 'E' => { 'H' => 30, 'G' => 150, 'D' => 80 } },
      { 'G' => { 'H' => 50 } },
      { 'H' => { 'D' => 90 } },
      { 'D' => {  } },
      { 'C' => { 'D' => 200 } }
    ]
  end

  def shortest_path(start, finish)
    find_shortest_path(start, finish, @nodes, @next_matrix)
  end

  def shortest_distance(nodes, start, finish)
    floyd_warshall(adjacency_matrix(nodes), nodes_numbered(nodes)[start], nodes_numbered(nodes)[finish])
  end

  def denormalise_nodes(nodes)
    nodes.map { |k, v| [k => v] }.flatten
  end

  private

  def find_shortest_path(start, finish, nodes, next_matrix, path = [])
    nodes_numbered = nodes_numbered(nodes)

    numbered_start = nodes_numbered[start]
    numbered_finish = nodes_numbered[finish]

    if !next_matrix[numbered_start][numbered_finish]
      return path + [finish]
    else
      return find_shortest_path(
        next_matrix[numbered_start][numbered_finish],
        finish,
        nodes,
        next_matrix,
        path + [start])
    end
  end

  def mirror_paths(nodes)
    burried_nodes = Hash[nodes.keys.map { |x| [x, {}] }]

    Hash[burried_nodes.merge(nodes).to_a.map do |node|
      mergeable = Hash[nodes.select do |x|
        nodes[x].keys.include?(node[0])
      end.map do |k, v|
        [k, v[node[0]]]
      end]

      [node[0], node[1].merge(mergeable)]
    end]
  end

  def normalise_nodes(nodes)
    Hash[nodes.map { |x| [x.keys.first, x.values.first] }]
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

# map = Graph.new
# map.load_nodes(Graph.example_nodes)
# map.process_nodes

# ap map.shortest_path('A', 'E')
# ap map.shortest_distance('A', 'E')

# ap map.shortest_path('A', 'C')
# ap map.shortest_distance('A', 'C')

# ap map.shortest_path('D', 'A')
# ap map.shortest_distance('D', 'A')

# ap map.shortest_path('A', 'B')
# ap map.shortest_distance('A', 'B')

# TODO: Handle sparse node ------X
# TODO: Check without D key
