

function algoAstar(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})

    h(M,a,b) = distance(M,a,b)

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

    origin = Dict{Tuple{Int64,Int64}, Tuple{Int64, Int64}}([(D,D)])
    cost = Dict{Tuple{Int64,Int64}, Int64}([(D,0)])

    while !isempty(frontier)

        current = popfirst!(frontier)[1]
        visitedCells += 1

        if current == A 
            found = true
            break
        end

        neighbors = getNeighbors(map,current)

        for next in neighbors 
            new_cost = movingCost(map, current, next) + cost[current]
            
            if !haskey(cost, next) || new_cost < cost[next]  
                cost[next] = new_cost
                frontier[next] = new_cost + h(map, A, next)
                origin[next] = current
            end
        end
    end

    if found == true 
        (s,len) = createPath(origin, A, D)
        println("Path found !! Here it is : " * s)
        println("Length of the path from D to A : " * string(len))
        println("Number of visited cells : " * string(visitedCells))
    else
        println("No feasible path")
    end

end

function createPath(path::Dict{Tuple{Int64,Int64}, Tuple{Int64, Int64}}, A::Tuple{Int64,Int64}, D::Tuple{Int64,Int64})

    s = string((A[2]-1,A[1]-1))
    current = A
    len::Int64 = 0

    while current != D
        node = path[current]
        node = (node[2]-1,node[1]-1)
        s = string(node) * "→" * s
        current = path[current]
        len +=1
    end
    return s,len
end

