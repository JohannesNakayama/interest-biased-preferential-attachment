using Clustering
using Graphs
using UnicodePlots
using Distances
using DataFrames

include("test.jl")

s = IBPA.sample(IBPA.IBPAModel(1000, 10, 3, 3, 0.5), 10)
x = deepcopy(s[1].node_interest_map)

pair_array = [(i, x[i]) for i in keys(x)]

df = DataFrame(pair_array)
rename!(df, [:NodeID, :Interest])


m = Matrix(adjacency_matrix(s[1].g))

sim = zeros(1000, 1000)

for i in 1:1000
    for j in 1:1000
        sim[i, j] = hamming(m[i, :], m[j, :])
        sim[j, i] = copy(sim[i, j])
    end
end


clus = hclust(sim)

sim = sim[clus.order, clus.order]

heatmap(sim, width = 50, colorbar = false)
