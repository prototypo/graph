
## Installation
```
git clone git@github.com:rcaught/graph.git
cd ruby/
gem install sinatra

ruby server.rb

# Open browser to: http://localhost:4567
# or
# curl -X POST -H "Content-Type: application/json" -d '{ "A": { "B": 80 } }' http://localhost:4567/
# etc...
```

## I am aware of
- Reassignment to `@nodes` in `load_nodes` during merge.
- The limitations of class variable storage (used for persistence).
- Extra work done on finding the shortest path (out of spec).  Was useful for testing though.
- A DP approach to the Floyd–Warshall Algo, should be recursive.  Would argue that the DP approach is best here though.

## Feedback on the provided problem:
- Some code example values do not match the problem text
