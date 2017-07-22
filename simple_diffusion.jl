using LightGraphs

struct Diffusion
  graph::Graph
  reached::Set{Int64}
  intermediate_reached::Set{Int64}
  to_watch::Set{Int64}
  p::Float64
  normalize_p::Bool
end


"""

    diffusion_simulation(g, p, num_steps;
                         to_watch=Set(vertices(g))
                         initial_at_risk=Set(vertices(g)),
                         normalize_p=false
                         )

### Implementation Notes

Runs diffusion simulation on `g` for `num_steps` with spread
probabilities based on `p`.

Returns an Array with number of vertices reached at each step of
simulation.

While simulation is always run on full graph, specifying `to_watch`
allows for reporting of the number of vertices reached within
a subpopulation.

If `normalized_p` is `false`, the probability of spread from a vertex i to
each of the out_neighbors of `i` is `p`.

If `normalized_p` is `true`, the probability of spread from a vertex `i` to
each of the out_neighbors of `i` is `p / degree(g, i)`.

"""

function diffusion_simulation(g::Graph,
                              p::Float64,
                              num_steps::Int64;
                              to_watch::Set{Int64}=Set(vertices(g)),
                              initial_at_risk::Set{Int64}=Set(vertices(g)),
                              normalize_p::Bool=false)

  simulation = Diffusion(g,
                         Set{Int64}(),
                         Set{Int64}(),
                         to_watch,
                         p,
                         normalize_p)

  vertices_reached = zeros(Int64, num_steps)

  # Initiate
  initial_infection(simulation, initial_at_risk)

  # Run for num_steps
  for step in 1:num_steps
    for i in simulation.reached
      infect_neighbors(simulation, i)
    end

  # flip state vectors
  union!(simulation.reached, simulation.intermediate_reached)

  # Get infection rate
  vertices_reached[step] = length( intersect(simulation.reached, simulation.to_watch) )
  end

  return vertices_reached

end

function initial_infection(simulation::Diffusion, initial_at_risk)
  i = rand(initial_at_risk)
  push!(simulation.reached, i)
end

function infect_neighbors(simulation, i)

  if simulation.normalize_p
    p = simulation.p / degree(simulation.graph, i)
  else
    p= simulation.p
  end

  for n in out_neighbors(simulation.graph, i)
    if rand(Float16) < p
      push!(simulation.intermediate_reached, n)
    end
  end

end
