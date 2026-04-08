struct Truck
    id::Int64                                   # the truck's number, unique for all trucks 
    dock::Int64                                 # the dock where the truck will wait
    arrival::Int64                              # the arrival time of the truck
    departure::Int64                            # the departure time of the truck
end

struct Point
    x::Int64                                    # the x-coordinate of the point
    y::Int64                                    # the y-coordinate of the point
end

struct Dock                                     
    id::Int64                                   # the dock's number, unique for all docks
    loc::Point                                  # the location of the dock in the map
end

mutable struct AMR
    id::Int64                                   #  the AMR's number, unique for all AMR
    path::Vector{Point}                         #  the optimal path for the AMR
    startingDock::Int64                         #  the starting dock of the AMR      
    goalDock::Int64                             #  the dock goal of the AMR
    departureTime::Int64                        #  the time at which the AMR can start its mission
    arrivalTime::Int64                          #  the time at which the AMR finish his mission, updated at the end of the A* application
end

struct Interval                                 # In order to store the safe intervals of the map's nodes
    start_t::Float64        
    end_t::Float64
end

mutable struct SIPPnode
    c::Char                                     # The character at the location of the SIPPnode in the original map
    intervals::Vector{Interval}                 # A vector of intervals where the node is clear
end

struct InstanceAMR
    map::Matrix{SIPPnode}                       # the map of the instance
    docks::Vector{Dock}                         # the docks of the instance
    amrs::Vector{AMR}                           # the AMRs of the instance
    trucks::Vector{Truck}                       # the trucks of the instance
end

struct SolutionAMR
    map::Matrix{SIPPnode}                       # The map of the instance, used for computing images
    amrs::Vector{AMR}                           # The final version of the AMR. Each of them has the best path according to the A* algorithm, considering an order of priority
    endTime::Int64                              # The maximum of arrival times for all AMR

    tElapsed::Float64                           # The total time used for computing a solution. !! This time doesn't take the time used for displaying solution into account 
end

# Redifining the ∈ operator for the Interval datastrucure
function Base.in(x::Int64, I::Interval)
    return I.start_t <= x <= I.end_t
end
