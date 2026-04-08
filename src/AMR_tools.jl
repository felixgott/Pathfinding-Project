function getNeighbors(map::Matrix{SIPPnode}, a::Point, t::Int64, impMvt::Dict{Int64,Set{Tuple{Point,Point}}})
    i,j = a.x,a.y                                                                               # collect the actual coordinates
    neighbors::Array{Point} = [Point(i-1,j),Point(i+1,j),Point(i,j-1),Point(i,j+1), a]          # an array of point that contains all the possible coordinates that are right next to the actual point, plus the actual one
    return [b for b in neighbors if possibleMovement(map,a,b,t,impMvt)]                         # return neighbors that can be reached from the actual location, at time t
end

function possibleMovement(map::Matrix{SIPPnode}, a::Point, b::Point, t::Int64, impMvt::Dict{Int64,Set{Tuple{Point,Point}}})
    if isInMap(map,a) && isInMap(map,b) && validChar(map,b)                 # Check if a and b are both in the map, and if b represent a valid character
        for SI in map[b.x,b.y].intervals                                    # Check if, when we will be at the point, i.e. at time t+1, this time is contained in a safe interval of the node
            if t+1 ∈ SI 
                return !(haskey(impMvt, t) && (b,a) ∈ impMvt[t]) || a==b   
            end
        end
    end 
    return false
end

function isInMap(map, p::Point) 
    m,n = size(map)
    return 1 <= p.x <= m && 1 <= p.y <= n
end

function validChar(map,a)
    char = map[a.x,a.y].c
    return char != '@' && char != 'T' && char != 'O'
end

function movingCost(M,b)
    char = M[b.x,b.y].c
    if char == '.' || char == 'G'   # ground
        return 1
    elseif char == 'S'              # slow
        return 3  
    else 
        return 9999999
    end
end

function distance(a,b)
    return Float64(abs(a.x-b.x) + abs(a.y-b.y))
end

function idDockToPoint(d::Int64, docks::Vector{Dock}) # return the location of the dock with its id = d, in the map
    for dock in docks
        if dock.id == d
            return dock.loc
        end
    end
    return error("No such dock")
end

function orderPriority(amrs::Vector{AMR}, trucks::Vector{Truck})    
    # Return a priority queue with all AMRs
    # It works as follow : 
    # Each AMR's goal dock is associate to one truck, then we order them by order of prioriy of the truck's departure time
    dockToTruck = Dict(t.dock => t for t in trucks)
    PQ = PriorityQueue{AMR, Int64}()

    for amr in amrs 
        truck = get(dockToTruck, amr.goalDock, nothing)
        
        if truck !== nothing
            priority_score = truck.departure
        else
            priority_score = 999999             # No truck is assigned to the arrival dock of this AMR
        end

        enqueue!(PQ, amr, priority_score)
    end
    return PQ
end



function updatePath!(amr::AMR, pathIN::Dict{Tuple{Point,Int64}, Tuple{Point,Int64}}, impossibleMvmt::Dict{Int64,Set{Tuple{Point,Point}}}, map::Matrix{SIPPnode}, docks)
    # Create the path for this AMR, while adding impossibles mouvements
    path = Point[]                                                  # Create a vector of Point for constructing the path
    current = idDockToPoint(amr.goalDock, docks)
    goalPoint = idDockToPoint(amr.startingDock, docks)
    current_time = amr.arrivalTime                                  # starting by the end

    while (current,current_time) != (goalPoint,amr.departureTime)   # The current state is not the departure state
        pushfirst!(path,current)                                    # We add this state at the beginning of the path
        
        
        if !haskey(pathIN, (current,current_time))
            error("Error while reconstructing the path")
        end

        updateSafeIntervals!(map, current, current_time)            # update safes intervals of the current node

        parent_point, parent_time = pathIN[(current,current_time)]  

        if !haskey(impossibleMvmt, parent_time)
            impossibleMvmt[parent_time] = Set{Tuple{Point, Point}}() # create a set of impossible mouvements for the time parent_time 
        end

        push!(impossibleMvmt[parent_time], (parent_point, current)) # update impossible mouvements by adding the move from its parent to the current node , at time parent_time

        current, current_time = parent_point, parent_time
    end

    pushfirst!(path, goalPoint)                                     # Push the first point to the path
    updateSafeIntervals!(map, goalPoint, amr.departureTime)         # Update safe intervals for the start
    amr.path = path                                                 # Update the path of this AMR with the one we just create
end


function updateSafeIntervals!(map::Matrix{SIPPnode}, loc::Point, t::Int64)
    safeInterval = map[loc.x,loc.y].intervals                       # load actuals intervals of the node

    newIntervals = Interval[]                                       # creating the future vector of safe intervals for this point
    
    for SI in safeInterval                                          # adding the new intervals to the vector, considering the time t
        if t ∈ SI
            if SI.start_t < t
                push!(newIntervals, Interval(SI.start_t, t - 1.0))
            end
            if SI.end_t > t
                push!(newIntervals, Interval(t + 1.0, SI.end_t))
            end
        else
            push!(newIntervals, SI)                                
        end
    end

    map[loc.x,loc.y].intervals = newIntervals
end



function parse_file(filepath::String)
    # Used for parsing the data file
    amrs = AMR[]        #   ┐
    docks = Dock[]      #  ┤   One vector for each datastrucure
    trucks = Truck[]    # ┘
    
    current_section = ""
    lines = readlines(filepath) # collecting all lines of the file
    map_lines = String[]        # a Vector of string, each element correspond to one line of the map
    reading_map = false

    for line in lines                   # reading line by line
        line = strip(line)
        isempty(line) && continue
        
        if occursin("@", line) && !reading_map     # starting reading the map if we see a '@' character in the line
            reading_map = true
            push!(map_lines, line)
            continue
        elseif reading_map
            push!(map_lines, line)
            continue
        end

        if startswith(line, "AMR;")                # AMR's section 
            current_section = "AMR"
            continue
        elseif startswith(line, "DOCK;")           # Dock's section
            current_section = "DOCK"
            continue
        elseif startswith(line, "TRUCKS;")         # Truck's section
            current_section = "TRUCKS"
            continue
        end

        parts = split(line, ";")

        if current_section == "AMR"                 # collecting AMR datas
            push!(amrs, AMR(parse(Int, parts[1]), Point[],parse(Int, parts[2]), parse(Int, parts[3]), parse(Int,parts[4]), 9999999))

        elseif current_section == "DOCK"            # collecting docks datas
            id = parse(Int, parts[1])
            coords = replace(parts[2], "(" => "", ")" => "")
            xy = split(coords, ",")
            push!(docks, Dock(id, Point(parse(Int, xy[1]), parse(Int, xy[2]))))

        elseif current_section == "TRUCKS"          # collecting trucks datas
            push!(trucks, Truck(parse(Int, parts[1]), parse(Int, parts[2]), parse(Int, parts[3]), parse(Int, parts[4])))
        end
    end

    # reconstructing the map, from a vector of string to a matrix of SIPPnode
    if !isempty(map_lines)
        rows = length(map_lines)
        cols = length(map_lines[1])
        map = Matrix{SIPPnode}(undef, rows, cols)
        for r in 1:rows
            for c in 1:cols
                map[r, c] = SIPPnode(map_lines[r][c], Vector{Interval}([Interval(0.,Inf)]))
            end
        end
    end

    return amrs, docks, trucks, map
end

