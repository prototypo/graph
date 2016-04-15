require 'sinatra'
require 'json'
require './lib/map'

post '/' do
  data = JSON.parse(request.body.read)

  @map = Map.new
  @map.load_nodes(Map.example_nodes)
  @map.process_nodes

  if data['start'] && data['end']
    if @map.nodes.keys.include?(data['start']) && @map.nodes.keys.include?(data['end'])
      return { 'distance' => @map.shortest_distance(data['start'], data['end']) }.to_json
    else
      # 40X
    end
  end
end
