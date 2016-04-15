require 'sinatra'
require 'json'
require './lib/map'
require 'awesome_print'

before do
  if !defined?(@@map)
    @@map = Map.new
    @@map.load_nodes([])
    @@map.process_nodes
  end
end

post '/' do
  data = JSON.parse(request.body.read)

  if data['map']
    @@map.load_nodes(data['map'])
    @@map.process_nodes
  end

  if data['start'] && data['end']
    if @@map.nodes.keys.include?(data['start']) && @@map.nodes.keys.include?(data['end'])
      return { 'distance' => @@map.shortest_distance(data['start'], data['end']) }.to_json
    else
      status 400
    end
  end
end

get '/' do
  @@map.nodes.ai(html: true)
end
