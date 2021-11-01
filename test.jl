module IBPA

# Dependencies
using Graphs
using Random
using StatsBase
using UnicodePlots

# User API
export IBPAModel
export IBPANetwork
export sample

# Interest-biased preferential attachment model
mutable struct IBPAModel
    n::Int
    m_0::Int
    m::Int
    n_interests::Int
    self_weight::Float64
end

# Interest-biasel preferential attachment network (instantiance of the above model)
mutable struct IBPANetwork
    g::AbstractGraph
    node_interest_map::Dict
end

# Sample from a given IBPA model
function sample(model::IBPAModel, samples)
    samp = [evolve_model(model) for i in 1:samples]
    return samp
end

# Evolve a given model
function evolve_model(model)

    g = Graphs.SimpleGraph(model.m_0)
    node_interest_map = Dict([(i, Random.rand(1:model.n_interests)) for i in 1:nv(g)])

    for new_node in (model.m_0 + 1):model.n

        node_degrees = degree(g)

        new_node_interest = Random.rand(1:model.n_interests)

        interest_weights = calculate_interest_weights(g, node_interest_map, new_node_interest, model.n_interests, model.self_weight)

        node_weights = sum(node_degrees) == 0 ? repeat([1 / nv(g)], nv(g)) : node_degrees / sum(node_degrees)
        interest_weights /= sum(interest_weights)

        weights = (node_weights + interest_weights) / 2
        samp = StatsBase.sample(1:nv(g), Weights(weights), model.m, replace = false)

        add_vertex!(g)
        for att in samp
            add_edge!(g, (nv(g), att))
        end

        node_interest_map[nv(g)] = new_node_interest

    end

    return IBPANetwork(g, node_interest_map)
end

# Calculate the weights for each node given its interest
function calculate_interest_weights(g::AbstractGraph, node_interest_map, new_node_interest, n_interests, self_weight)
    interest_weights = ones(nv(g))

    for k in keys(node_interest_map)
        if node_interest_map[k] == new_node_interest
            interest_weights[k] = self_weight
        else
            interest_weights[k] = (1 - self_weight) / (n_interests - 1)
        end
    end

    return interest_weights
end

end  # end module


# create m_0 initial nodes
#
# add a new node to the network and attach it to m <= m_0 existing nodes
#   do this weighted by the existing nodes' degrees
#
# finish when the node count = n

# now, add another parameter: the number of interest clusters represented in the network
# suppose, there are 3 interest clusters in the network
# the preferential attachment is then not only weighted by the existing nodes' degree, but also by the interest of a connecting node
# each node has one of the interests represented in the network

# self_weight = 1 / n_interests  # default: BA equivalent











