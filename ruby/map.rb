require 'set'
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
      'D' => { 'H' => 90, 'D' => 200 },
      'C' => { 'D' => 200, 'A' => 30 }
    }
  end

  def shortest_path(origin:, destination:)
    # Dijkstra's algorithm
    # https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm

    node_distances = example_nodes.map { |k, v| [k, Float::INFINITY] }.to_h.merge({ origin => 0 })

    unvisited_nodes = Set.new(example_nodes.keys - [origin])
    visited_nodes = Set.new

    neighbours = example_nodes[origin]
    unvisited_neighbours = neighbours.select { |node| !visited_nodes.include?(node) }

    unvisited_neighbours.each do |node, distance|
      if origin + distance > node_distances[node]
        node_distances[node] = distance
      end
    end

    visited_nodes << origin
    unvisited_nodes - [origin]

    binding.pry
  end
end

map = Map.new
map.shortest_path(origin: 'A', destination: 'D')
