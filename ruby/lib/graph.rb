require 'matrix'

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

  def shortest_distance(nodes, start, finish)
    nodes_numbered = nodes_numbered(nodes)
    numbered_nodes = numbered_nodes(nodes)

    floyd_warshall(adjacency_matrix(nodes, numbered_nodes), nodes_numbered[start], nodes_numbered[finish])
  end

  def denormalise_nodes(nodes)
    nodes.map { |k, v| [k => v] }.flatten
  end

  private

  # https://en.wikipedia.org/wiki/Floyd–Warshall_algorithm
  def floyd_warshall(adjacency_matrix, i, j)
    if i == j
      return 0
    end

    if i == j - 1
      return adjacency_matrix[i][j]
    end

    return ((i + 1)...j).reduce(Float::INFINITY) do |max, k|
      x = [adjacency_matrix[i][j], floyd_warshall(adjacency_matrix, i, k) + floyd_warshall(adjacency_matrix, k, j)].min

      x < max ? x : max
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

  def adjacency_matrix(nodes, numbered_nodes)
    adjacency_matrix = Matrix.build(nodes.keys.size) { Float::INFINITY }.to_a

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

  def numbered_nodes(nodes)
    nodes.map.with_index.map { |(k, v), i| [i, k] }.to_h
  end

  def nodes_numbered(nodes)
    numbered_nodes(nodes).invert
  end
end
