using LightGraphs
using GraphIO

path = open("/users/nick/desktop/anon_edgelist.edgelist", "r")
g = loadgraph(path, "g",  EdgeListFormat())

struct Diffusion
  graph::SimpleGraph
  primary_state::Vector{Int64}
  updating_state::Vector{Int64}
  to_watch::Vector{Int64}
  p::Float64
end


function diffusion_simulation(g::SimpleGraph,
                              to_watch::Vector{Int64}),
                              p::Float64,
                              num_steps::Int64)
  simulation = Diffusion(g,
                         zeros(Int64, nv(g)),
                         zeros(Int64, nv(g)),
                         to_watch, p)

  infected = zeros(Float64, num_steps)

  # Initiate
  initial_infection(simulation)

  # Run for num_steps
  for step in 1:num_steps:
    for i in filter(x -> x == 1, simulation.primary_state)
      infect_neighbors(simulation, i)
    end

  # flip state vectors
  simulation.primary_state = copy(simulation.updating_state)

  # Get infection rate
  infected[step] = mean(simulation.primary_state[simulation.to_watch])
  end

  return infected

end

function initial_infection(simulation::Diffusion)
  i = rand(1:nv(g))
  simulation.primary_state[i] = 1
end

function infect_neighors(simulation, i)
  for n in neighbors(i)
    if randn < p
      simulation.updating_state[n] = 1
    end

  end
