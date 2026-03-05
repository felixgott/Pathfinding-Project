
function algoGreedy(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})

    # Definitino of the heuristic fonction to evalute the heuristic between the goal and the current cell 
    h(M,a,b) = distance(M,a,b)

    # Update of the coordinates for the base in JuLIA
    A = (A[2]+1,A[1]+1)
    D = (D[2]+1,D[1]+1)

    map = extractMapFromFile(fname)
    #map = ['.' '.' '.' '.'; 
    #       'S' '@' '@' '@'; 
    #       'W' 'S' '@' '.'; 
    #       '@' '.' 'S' 'S']

    if !isInMap(map,D) || !isInMap(map,A)
        return ErrorException("One of those point is not in the map")
    end

    if !validChar(map,D) || !validChar(map,A)
        return ErrorException("One of those points can't be reached")
    end

    frontier = PriorityQueue{Tuple{Int64,Int64}, Float64}()
    frontier[D] = 0
    found = false
    visitedCells::Int64 = 0
    visited = Set{Tuple{Int64,Int64}}()
    path = Dict{Tuple{Int64,Int64}, Tuple{Int64, Int64}}([(D,D)])

    while !isempty(frontier)

        current = popfirst!(frontier)[1]
        push!(visited,current)
        visitedCells += 1

        if current == A 
            found = true
            break
        end

        neighbors = getNeighbors(map,current)
        for next in neighbors 
            
            if !haskey(frontier, next) && !(next in visited)                # the next cell is not in the frontier so we're adding it
                frontier[next] = h(map,A,next)        # the value is the heuristic function evalute between the goal and the next cell
                path[next] = current                # saving the path
            end
        end
    end

    if found == true 
        (s,len) = createPath(path, A, D)
        println("Path found !! Here it is : " * s)
        println("Length of the path from D to A : " * string(len))
        println("Number of visited cells : " * string(visitedCells))
    else
        println("No feasible path")
    end

end

function createPath(path::Dict{Tuple{Int64,Int64}, Tuple{Int64, Int64}}, A::Tuple{Int64,Int64}, D::Tuple{Int64,Int64})

    s = string((A[2]-1,A[1]-1))         # putting back the coordinates in the goog order
    current = A
    len::Int64 = 0

    while current != D
        node = path[current]
        node = (node[2]-1,node[1]-1)    #  putting back the coordinates in the goog order
        s = string(node) * "→" * s
        current = path[current]
        len +=1
    end
    return s,len
end

