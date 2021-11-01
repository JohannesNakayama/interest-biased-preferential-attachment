using Graphs
using Random
using StatsBase
using UnicodePlots

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

n = 1000
m_0 = 10
m = 3
n_interests = 3
# own_interest_weight = 1 / n_interests  # default: BA equivalent
own_interest_weight = 0.5

G = SimpleGraph(m_0)
node_interest_map = Dict([(i, Random.rand(1:n_interests)) for i in 1:10])

for new_node in (m_0 + 1):n

    node_degrees = degree(G)

    new_node_interest = Random.rand(1:n_interests)

    interest_weights = ones(nv(G))

    for k in keys(node_interest_map)
        if node_interest_map[k] == new_node_interest
            interest_weights[k] = own_interest_weight
        else
            interest_weights[k] = (1 - own_interest_weight) / (n_interests - 1)
        end
    end

    node_weights = sum(node_degrees) == 0 ? repeat([1 / nv(G)], nv(G)) : node_degrees / sum(node_degrees)
    interest_weights /= sum(interest_weights)

    weights = (node_weights + interest_weights) / 2
    samp = StatsBase.sample(1:nv(G), Weights(weights), m, replace = false)

    add_vertex!(G)
    for att in samp
        add_edge!(G, (nv(G), att))
    end

    node_interest_map[nv(G)] = new_node_interest

end


histogram(degree(G), bins = 50)




