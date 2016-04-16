
## Installation
```
git clone git@github.com:rcaught/graph.git
cd Graph/ruby/
gem install sinatra awesome_print

ruby server.rb

# Open browser to: http://localhost:4567
# or
# curl -X POST -H "Content-Type: application/json" -d '{ "A": { "B": 80 } }' http://localhost:4567/
# etc...

# to run tests
ruby tests/graph_test.rb
```

## Usage
Fresh loading map data:
```
{
    "map": [
        {"A": { "B": 100, "C": 30 }},
        {"B": { "F": 300}},
        {"C": { "D": 200}},
        {"D": { "H": 90, "E":80}},
        {"E": { "H": 30, "G":150, "F":50}},
        {"F": { "G":70}},
        {"G": { "H":50}}
    ]
}
```

Modifying / adding map data:
```
{ "A": { "B": 80 } } 
```

Deleting paths:
```
{ "A": { "B": null } }
```

Deleting nodes:
```
{ "A": null }
```

Calculating shortest distance:
```
{ "start":"A", "end":"F" }
```

## Problems I am aware of:
- The limitations of the servers class variable storage (used for persistence).
- Lack of depth in deleting nodes and paths

## Feedback on the provided problem:
- Some code example values do not match the problem text
