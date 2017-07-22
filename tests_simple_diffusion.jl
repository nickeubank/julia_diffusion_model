include("simple_diffusion.jl")

g = CompleteGraph(5)
for i in 1:5
  add_vertex!(g)
end
neighbors(g, 1)

# Basic test. Watch connected vertices
result = diffusion_simulation(g,
                              1.0,
                              4,
                              to_watch=Set(1:5),
                              initial_at_risk=Set(1:5)
                              )
result
assert(result == [5, 5, 5, 5])

# Watching unconnected vertices
result = diffusion_simulation(g,
                              1.0,
                              4,
                              to_watch=Set(6:10),
                              initial_at_risk=Set(1:5)
                              )
assert( result == [0, 0, 0, 0])


result = diffusion_simulation(g,
                              1.0,
                              4,
                              to_watch=Set(1:2),
                              initial_at_risk=Set(1:5)
                              )
                              result
assert( result == [2, 2, 2, 2] )

result = diffusion_simulation(g,
                              1.0,
                              4,
                              to_watch=Set(1:5),
                              initial_at_risk=Set(10)
                              )

assert( result == [0, 0, 0, 0] )

# Check along path graph
g2 = PathGraph(5)
result = diffusion_simulation(g2,
                              1.0,
                              4,
                              to_watch=Set(1:5),
                              initial_at_risk=Set(1)
                              )

assert( result == [2, 3, 4, 5] )

result = diffusion_simulation(g2,
                              1.0,
                              4,
                              to_watch=Set(1:5),
                              initial_at_risk=Set(3)
                              )

assert( result == [3, 5, 5, 5] )
