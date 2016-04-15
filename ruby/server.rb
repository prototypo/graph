require 'sinatra'
require 'json'
require './lib/map'
require 'awesome_print'

before do
  if !defined?(@@map)
    @@map = Map.new
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
    @@map.process_nodes

    return @@map.nodes.to_json

  elsif data['start'] && data['end']
    if @@map.all_nodes(@@map.nodes).include?(data['start']) && @@map.all_nodes(@@map.nodes).include?(data['end'])
      return { 'distance' => @@map.shortest_distance(data['start'], data['end']) }.to_json
    else
      status 400

      return 'Submission Error'
    end

  else
    @@map.load_nodes(data, true)
    @@map.process_nodes

    return @@map.nodes.to_json
  end
end

get '/' do
  erb :index
end
