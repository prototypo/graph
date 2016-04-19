require 'minitest/autorun'
require './lib/graph'

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

class TestGraph < MiniTest::Unit::TestCase
  def setup
    @graph = Graph.new
  end

  def example_nodes
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

  def test_floyd_warshall
    @graph.nodes = @graph.process_nodes(example_nodes)
    numbered_nodes = @graph.send(:numbered_nodes, @graph.nodes)
    nodes_numbered = @graph.send(:nodes_numbered, @graph.nodes)
    adjacency_matrix = @graph.send(:adjacency_matrix, @graph.nodes, numbered_nodes)

    assert_equal [30, [0, 2]], @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['C'])
    assert_equal [230, [0, 2, 7]], @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['D'])
    assert_equal [0, [0, 0]], @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['A'])
    assert_equal [230, [7, 2, 0]], @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['D'], nodes_numbered['A'])
    assert_equal [360, [0, 2, 7, 4, 3]], @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['F'])
  end

  def test_denormalise_nodes
    denormalised = [
        { "A" => { "B" => 100, "C" => 30 } },
        { "B" => { "F" => 300 } },
        { "F" => { "E" => 50, "G" => 70 } },
        { "E" => { "H" => 30, "G" => 150, "D" => 80 } },
        { "G" => { "H" => 50 } },
        { "H" => { "D" => 90 } },
        { "D" => {} },
        { "C" => { "D" => 200 } }
      ]

    assert_equal denormalised, @graph.denormalise_nodes(@graph.send(:normalise_nodes, example_nodes))
  end

  def test_normalise_nodes
    normalised = {
        "A" => { "B" => 100, "C" => 30 },
        "B" => { "F" => 300 },
        "F" => { "E" => 50, "G" => 70 },
        "E" => { "H" => 30, "G" => 150, "D" => 80 },
        "G" => { "H" => 50 },
        "H" => { "D" => 90 },
        "D" => {},
        "C" => { "D" => 200 }
      }

    assert_equal normalised, @graph.send(:normalise_nodes, example_nodes)
  end

  def test_shortest_distance
    @graph.nodes = @graph.process_nodes(example_nodes)

    assert_equal 30, @graph.shortest_distance(@graph.nodes, 'A', 'C')
    assert_equal 230, @graph.shortest_distance(@graph.nodes, 'A', 'D')
    assert_equal 230, @graph.shortest_distance(@graph.nodes, 'D', 'A')
  end

  def test_shortest_path
    @graph.nodes = @graph.process_nodes(example_nodes)

    assert_equal ['A', 'C'], @graph.shortest_path(@graph.nodes, 'A', 'C')
    assert_equal ['A', 'C', 'D'], @graph.shortest_path(@graph.nodes, 'A', 'D')
    assert_equal ['D', 'C', 'A'], @graph.shortest_path(@graph.nodes, 'D', 'A')
  end

  def test_mirror_paths
    mirrored_paths = {
        "A" => { "B" => 100, "C" => 30 },
        "B" => { "F" => 300, "A" => 100 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200, "A" => 30 }
      }

    @graph.nodes = @graph.process_nodes(example_nodes)

    assert_equal mirrored_paths, @graph.send(:mirror_paths, @graph.nodes)

    nodes_with_buried_node = example_nodes.reject { |x| x.keys[0] == 'D' }

    @graph.nodes = @graph.process_nodes(nodes_with_buried_node)

    assert_equal mirrored_paths, @graph.send(:mirror_paths, @graph.nodes)
  end

  def test_all_nodes
    example = {
        "A" => { "B" => 100, "C" => 30 },
        "D" => { "E" => { "F" => { "G" => 20}, "H" => { "I" => { "J" => { "K" => 10 } } } } }
      }

    result = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']

    assert_equal result, @graph.send(:all_nodes, example)
  end

  def test_adjacency_matrix
    adjacency_matrix = [
        [0, 100, 30, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY],
        [100, 0, Float::INFINITY, 300, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY],
        [30, Float::INFINITY, 0, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, 200],
        [Float::INFINITY, 300, Float::INFINITY, 0, 50, 70, Float::INFINITY, Float::INFINITY],
        [Float::INFINITY, Float::INFINITY, Float::INFINITY, 50, 0, 150, 30, 80],
        [Float::INFINITY, Float::INFINITY, Float::INFINITY, 70, 150, 0, 50, Float::INFINITY],
        [Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, 30, 50, 0, 90],
        [Float::INFINITY, Float::INFINITY, 200, Float::INFINITY, 80, Float::INFINITY, 90, 0]
      ]

    @graph.nodes = @graph.process_nodes(example_nodes)
    numbered_nodes = @graph.send(:numbered_nodes, @graph.nodes)

    assert_equal adjacency_matrix, @graph.send(:adjacency_matrix, @graph.nodes, numbered_nodes)
  end

  def test_process_nodes
    fresh_load = {
        "A" => { "B" => 100, "C" => 30 },
        "B" => { "F" => 300, "A" => 100 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200, "A" => 30 }
      }

    assert_equal fresh_load, @graph.process_nodes(example_nodes)
  end

  def test_delete_node
    deleted_node = {
        "B" => { "F" => 300 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200 }
      }

    assert_equal deleted_node, @graph.process_nodes({ 'A' => nil }, @graph.process_nodes(example_nodes))
  end

  def test_delete_path
    deleted_path = {
        "A" => { "C" => 30 },
        "B" => { "F" => 300 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200, "A" => 30 }
      }

    assert_equal deleted_path, @graph.process_nodes({ 'A' => { 'B' => nil } }, @graph.process_nodes(example_nodes))
  end

  def test_update_path
    updated_path = {
        "A" => { "B" => 20, "C" => 30 },
        "B" => { "F" => 300, "A" => 20 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200, "A" => 30 }
      }

    assert_equal updated_path, @graph.process_nodes({ 'A' => { 'B' => 20 } }, @graph.process_nodes(example_nodes))
  end

  def test_numbered_nodes
    numbered_nodes = { 0 => "A", 1 => "B", 2 => "C", 3 => "F", 4 => "E", 5 => "G", 6 => "H", 7 => "D" }

    assert_equal numbered_nodes, @graph.send(:numbered_nodes, @graph.process_nodes(example_nodes))
  end

  def test_nodes_numbered
    nodes_numbered = { "A" => 0, "B" => 1, "C" => 2, "F" => 3, "E" => 4, "G" => 5, "H" => 6, "D" => 7 }

    assert_equal nodes_numbered, @graph.send(:nodes_numbered, @graph.process_nodes(example_nodes))
  end
end
