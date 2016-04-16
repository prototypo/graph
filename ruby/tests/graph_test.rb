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

    assert_equal 30, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['C'])
    assert_equal 230, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['D'])
    assert_equal 0, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['A'])
    assert_equal 230, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['D'], nodes_numbered['A'])
    assert_equal 360, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['F'])
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

    nodes_with_burried_node = example_nodes.reject { |x| x.keys[0] == 'D' }

    @graph.nodes = @graph.process_nodes(example_nodes)

    assert_equal mirrored_paths, @graph.send(:mirror_paths, @graph.nodes)
  end

  def test_adjacency_matrix
    adjacency_matrix = [
        [0, 100, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, 30],
        [100, 0, 300, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY],
        [Float::INFINITY, 300, 0, 50, 70, Float::INFINITY, Float::INFINITY, Float::INFINITY],
        [Float::INFINITY, Float::INFINITY, 50, 0, 150, 30, 80, Float::INFINITY],
        [Float::INFINITY, Float::INFINITY, 70, 150, 0, 50, Float::INFINITY, Float::INFINITY],
        [Float::INFINITY, Float::INFINITY, Float::INFINITY, 30, 50, 0, 90, Float::INFINITY],
        [Float::INFINITY, Float::INFINITY, Float::INFINITY, 80, Float::INFINITY, 90, 0, 200],
        [30, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, Float::INFINITY, 200, 0]
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

    update = {
        "A" => { "B" => 20, "C" => 30 },
        "B" => { "F" => 300, "A" => 100 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200, "A" => 30 }
      }

    delete_path = {
        "A" => { "C" => 30 },
        "B" => { "F" => 300 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200, "A" => 30 }
      }

    delete_node = {
        "B" => { "F" => 300 },
        "F" => { "E" => 50, "G" => 70, "B" => 300 },
        "E" => { "H" => 30, "G" => 150, "D" => 80, "F" => 50 },
        "G" => { "H" => 50, "F" => 70, "E" => 150 },
        "H" => { "D" => 90, "E" => 30, "G" => 50 },
        "D" => { "E" => 80, "H" => 90, "C" => 200 },
        "C" => { "D" => 200 }
      }

    @graph.nodes = @graph.process_nodes(example_nodes)

    # Fresh load
    assert_equal fresh_load, @graph.nodes

    # Update
    assert_equal update, @graph.process_nodes({ 'A' => { 'B' => 20 } }, @graph.nodes)

    # Delete path
    assert_equal delete_path, @graph.process_nodes({ 'A' => { 'B' => nil } }, @graph.nodes)

    # Delete node
    assert_equal delete_node, @graph.process_nodes({ 'A' => nil }, @graph.nodes)
  end
end
