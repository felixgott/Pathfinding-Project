
function algoGreedy(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    return algoGreedy(Instance(fname, extractMapFromFile(fname), Point(D[1], D[2]), Point(A[1], A[2])))
end


function algoGreedy(instance::Instance)

    # Definition of the heuristic fonction to evalute the heuristic between the goal and the current cell 
    map,D,A = instance.map, instance.S, instance.G

    h(M,a,b) = distance(M,a,b) # defining the heuristic used


    if validInstance(instance) 

        startT = time_ns()

        frontier = PriorityQueue{Point, Float64}()
        frontier[D] = 0
        found = false
        visitedCells::Int64 = 0
        visited = Set{Point}()
        path = Dict{Point, Point}([(D,D)])

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

        endT = time_ns()

        path_list = createPath(path, D, A)

        return Solution((endT - startT)/1e9, found, visitedCells, path, length(path_list)-1, -1)
    
    end
end

function algoDijkstra(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    return algoDijkstra(Instance(fname, extractMapFromFile(fname), Point(D[1], D[2]), Point(A[1], A[2])))
end


function algoDijkstra(instance::Instance)

    map,D,A = instance.map, instance.S, instance.G

    h(M,a,b) = distance(M,a,b) # defining the heuristic used


    if validInstance(instance)

        startT = time_ns()

        frontier = PriorityQueue{Point, Int64}()
        frontier[D] = 0
        
        found = false
        visitedCells::Int64 = 0

        path = Dict{Point, Point}([(D,D)])
        cost = Dict{Point, Int64}([(D,0)])

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
                    frontier[next] = new_cost
                    path[next] = current
                end
            end
        end

        endT = time_ns()

        path_list = createPath(path, D, A)

        return Solution((endT - startT)/1e9, found, visitedCells ,path, length(path_list)-1, cost[A])
    end
end



function algoBFS(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    return algoBFS(Instance(fname, extractMapFromFile(fname), Point(D[1], D[2]), Point(A[1], A[2])))
end


function algoBFS(instance::Instance)
    
    map,D,A = instance.map, instance.S, instance.G

    h(M,a,b) = distance(M,a,b) # defining the heuristic used


    if validInstance(instance)

        startT = time_ns()

        frontier::Queue{Point} = Queue{Point}()
        push!(frontier,D)
        visited::Dict{Point,Bool} = Dict([(D,true)]) 
        
        path::Dict{Point, Point} = Dict{Point, Point}([(D,D)])
        
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
        
        endT = time_ns()

        path_list = createPath(path, D, A)

        return Solution((endT - startT)/1e9, found, visitedCells ,path, length(path_list)-1, -1)
    
    end

end


function algoAstar(fname::String, D::Tuple{Int64,Int64}, A::Tuple{Int64,Int64})
    return algoAstar(Instance(fname, extractMapFromFile(fname), Point(D[1], D[2]), Point(A[1], A[2])))
end


function algoAstar(instance::Instance)
    
    map,D,A = instance.map, instance.S, instance.G

    h(M,a,b) = distance(M,a,b) # defining the heuristic used


    if validInstance(instance)

        startT = time_ns()

        frontier = PriorityQueue{Point, Float64}()
        frontier[D] = 0
        
        found = false
        visitedCells::Int64 = 0

        # Used for reconstructing the path
        path = Dict{Point, Point}([(D,D)])
        # In order to evaluate the best cost for each location
        cost = Dict{Point, Float64}([(D,0)])

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
                    path[next] = current
                end
            end
        end

        endT = time_ns()

        path_list = createPath(path, D, A)

        return Solution((endT - startT)/1e9, found, visitedCells, path, length(path_list)-1, cost[A])
    end
end 

