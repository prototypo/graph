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
    @graph.load_nodes(example_nodes)
    numbered_nodes = @graph.send(:numbered_nodes, @graph.nodes)
    nodes_numbered = @graph.send(:nodes_numbered, @graph.nodes)
    adjacency_matrix = @graph.send(:adjacency_matrix, @graph.nodes, numbered_nodes)

    assert_equal 30, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['C'])
    assert_equal 30, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['D'])
    assert_equal 30, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['A'])
    assert_equal 30, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['D'], nodes_numbered['A'])
    assert_equal 30, @graph.send(:floyd_warshall, adjacency_matrix, nodes_numbered['A'], nodes_numbered['F'])
  end
end