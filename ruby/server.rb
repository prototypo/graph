require 'sinatra'
require 'json'
require './lib/graph'
require 'awesome_print'

before do
  if !defined?(@@map)
    @@map = Graph.new
    @@map.load_nodes([])
  end
end

post '/' do
  begin
    data = JSON.parse(request.form_data? ? params['data'] : request.body.read)
  rescue
    status 400

    return 'Submission Error'
  end

  if data['map']
    @@map.load_nodes(data['map'])

    return @@map.nodes.to_json

  elsif data['start'] && data['end']
    if @@map.nodes.keys.include?(data['start']) && @@map.nodes.keys.include?(data['end'])
      return { 'distance' => @@map.shortest_distance(@@map.nodes, data['start'], data['end']) }.to_json
    else
      status 400

      return 'Submission Error'
    end

  else
    @@map.load_nodes(data, true)

    return @@map.nodes.to_json
  end
end

get '/' do
  erb :index
end
