
struct Point
    x::Int64       # the x-coordinate of the point
    y::Int64        # the y-coordinate of the point
end

struct Instance 
    name::String            # the name of the instance
    map::Matrix{Char}       # the matrix representing the map of the scenario
    S::Point                # the starting point of the scenario
    G::Point                # the goal point of the scenario
end


struct Solution
    tElapsed::Float64           # time consumed for computing the optimal solution according to the chosen algorithm

    found::Bool                 # Tells if the solution has been found

    nbStates::Int64             # the number of states evaluated
    path::Dict{Point,Point}     # the path of the Solution
    length::Int64               # the length of the path
    weight::Int64               # the total weight of the point
end