

function algoBFS(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    A = (A[2]+1,A[1]+1)
    D = (D[2]+1,D[1]+1)
    map = extractMapFromFile(fname)

    if !isInMap(map,D) || !isInMap(map,A)
        return ErrorException("One of those point is not in the map")
    end

    if !validChar(map,D) || !validChar(map,A)
        return ErrorException("One of those points can't be reached")
    end

    frontier::Queue{Tuple{Int64,Int64}} = Queue{Tuple{Int64,Int64}}()
    push!(frontier,D)
    visited::Dict{Tuple{Int64,Int64},Bool} = Dict([(D,true)]) 
    
    path::Dict{Tuple{Int64,Int64}, Tuple{Int64, Int64}} = Dict{Tuple{Int64,Int64}, Tuple{Int64, Int64}}([(D,D)])
    
    found = false
    visitedCells::Int64 = 0


    while !isempty(frontier) && !found

        current = popfirst!(frontier)
        visitedCells += 1

        if current == A 
            visited[current] = true
            found = true
        end

        neighbors = getNeighbors(map,current)
        for next in neighbors 
            if get(visited, next, false) == false
                push!(frontier,next)
                visited[next] = true
                path[next] = current
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

