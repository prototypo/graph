require 'matrix'
require 'set'

class Graph
  attr_accessor :nodes

  def process_nodes(nodes, existing_nodes = nil)
    if existing_nodes
      if nodes.values.first == nil
        delete_node(nodes, existing_nodes)

      elsif nodes.select { |k, v| v.values.any? { |x| x == nil } }.size > 0
        delete_path(nodes, existing_nodes)
      else
        update_path(nodes, existing_nodes)
      end
    else
      # Fresh loading nodes and paths
      mirror_paths(normalise_nodes(nodes))
    end
  end

  def shortest_distance(nodes, start, finish)
    dijkstras(nodes, [[0, [start]]], finish)[0]

    # nodes_numbered = nodes_numbered(nodes)
    # numbered_nodes = numbered_nodes(nodes)

    # floyd_warshall(adjacency_matrix(nodes, numbered_nodes), nodes_numbered[start], nodes_numbered[finish])[0]
  end

  def shortest_path(nodes, start, finish)
    dijkstras(nodes, [[0, [start]]], finish)[1]

    # nodes_numbered = nodes_numbered(nodes)
    # numbered_nodes = numbered_nodes(nodes)

    # result = floyd_warshall(adjacency_matrix(nodes, numbered_nodes), nodes_numbered[start], nodes_numbered[finish])[1]
    # result.map { |x| numbered_nodes[x] }
  end

  def denormalise_nodes(nodes)
    nodes.map { |k, v| [k => v] }.flatten
  end

  private

  # https://en.wikipedia.org/wiki/Floyd–Warshall_algorithm
  def floyd_warshall(adjacency_matrix, i, j, kn = nil)
    k = kn == nil ? adjacency_matrix[0].size - 1 : kn

    if k == 0
      return [adjacency_matrix[i][j], [i, j]]
    end

    a = floyd_warshall(adjacency_matrix, i, j, k - 1)
    b = floyd_warshall(adjacency_matrix, i, k, k - 1)
    c = floyd_warshall(adjacency_matrix, k, j, k - 1)

    [a, [b[0] + c[0], b[1] | c[1]]].min_by { |x| x[0] }
  end

  def dijkstras(nodes, i, j, visited = Set.new)
    current = i[0]
    rest = i.slice(1..-1)

    current_distance = current[0]
    current_path = current[1]

    key = current_path[0]
    path_rest = current_path.slice(1..-1)

    if key == j
      [current_distance, current_path.reverse]
    else
      paths = nodes[key].map { |k, d| !visited.include?(k) ? [current_distance + d, [k] + current_path] : nil }.compact
      sorted_paths = (paths + rest).sort { |a, b| a[0] <=> b[0] }

      dijkstras(nodes, sorted_paths, j, visited + [key])
    end
  end

  def mirror_paths(nodes)
    all_nodes = all_nodes(nodes).map { |x| [x, {}] }.to_h

    all_nodes.merge(nodes).to_a.map { |node|
      mergeable = nodes.select { |x| nodes[x].keys.include?(node[0]) }
                       .map { |k, v| [k, v[node[0]]] }.to_h

      [node[0], node[1].merge(mergeable)]
    }.to_h
  end

  def all_nodes(nodes)
    nodes.reduce([]) do |memo, (k, v)|
      if !v.values.first.is_a?(Hash)
        memo + [k] + v.keys
      else
        memo + [k] + v.keys + all_nodes(v.values.first)
      end
    end
  end

  def normalise_nodes(nodes)
    nodes.map { |x| [x.keys.first, x.values.first] }.to_h
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

  def delete_node(nodes, existing_nodes)
    existing_nodes.select { |k, v| k != nodes.keys.first }.
      map { |k, v| [k, v.select { |sk, sv| sk != nodes.keys.first }] }.to_h
  end

  def delete_path(nodes, existing_nodes)
    existing_nodes.map { |k, v| [k, v.reject { |sk, sv|
        sub_origin = nodes.keys.first
        sub_destination = nodes.values.first.keys.first

        (k == sub_destination || k == sub_origin) && (sk == sub_origin || sk == sub_destination)
      }] }.to_h
  end

  def update_path(nodes, existing_nodes)
    existing_nodes.merge(mirror_paths(nodes)) { |k, old_nodes, new_nodes| old_nodes.merge(new_nodes) }
  end
end
