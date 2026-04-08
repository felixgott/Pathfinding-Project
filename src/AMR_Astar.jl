# The A* algorithm implemented in order to respond to the problematic
function astarAMR(instance::InstanceAMR)
    startT = time_ns() 

    map,docks,trucks = instance.map, instance.docks, instance.trucks                # load variables of the instance
    amrSol = AMR[]                                                                  # create a Vector of AMR for the solution

    h(a,b) = distance(a,b)                                                      # defining the heuristic used


    impossibleMvmt = Dict{Int64,Set{Tuple{Point,Point}}}()                          # Define the mouvements that aren't posible to provide from collisions,
                                                                                    # e.g. : if an AMR goes from A to B at instant t, the movement from B to A at instant t will be added
    PQ_amr = orderPriority(instance.amrs,trucks)                                    # Define the priority order for treating the AMRs
    endTime = 0                                                                     # At start, all AMR have completed their tasks
        
    while !isempty(PQ_amr)                                                          # Treating AMR one by one, by order of priority
        current_AMR = popfirst!(PQ_amr)[1]
        t = current_AMR.departureTime                                               # The time at which the AMR start

        D = idDockToPoint(current_AMR.startingDock, docks)                          # The point that the AMR starts from, 
        A = idDockToPoint(current_AMR.goalDock, docks)                              # The point that the AMR has to reach

        # In what follows, a state is a pair of (Point,Int64) with Point ≝ the location, and Int64 ≝ the time 
        frontier = PriorityQueue{Tuple{Point,Int64}, Float64}()                     
                # The frontier of the points that we are exploring. 
                # It stores a state with the point representing the location on the map, and the integer representing the time at which we pass the point
                # It is sorted with the cost of the path from the start to the point, added to the heuristic evaluated with the goal and the point
        frontier[(D, t)] = 0. # The cost of arriving at the start, at the beginning of the simulation, is zero
        
        cost = Dict{Tuple{Point,Int64}, Float64}((D,t) => 0.0)                  # Stores the cost for each state that is needed to go from the start to the point
        path = Dict{Tuple{Point,Int64}, Tuple{Point,Int64}}((D,t) => (D,t))     # Stores pairs of states to reconstruct the path 
        final = nothing                                                         # The final state is nothing at beginning

        while !isempty(frontier)                                                # Exploring the map with the frontier
            (current, t)  = dequeue!(frontier)                                  # Going through the first state

            if current == A                                                     # Goal found
                final = (current, t)
                break
            end
            
            t_start = t
            if map[current.x, current.y].c == 'S'                               # Slow section
                for i in 1:3                                                    # We wait 3 units of time
                    T1 = t_start + 1
                    path[(current, T1)] = (current, t_start)                           # Staying here 
                    cost[(current, T1)] = cost[(current, t_start)] + 1.0               # cost for waiting
                    t_start = T1
                end
            end
            
            t = t_start 

            neighbors = getNeighbors(map, current, t, impossibleMvmt)           # Getting neighbors of the current node. t has been updated if we waited on a node
            
            for next in neighbors                                               
                T1 = t + 1
                new_cost = movingCost(map, next) + cost[(current, t)]           # Evaluating the cost if we pass by this node      
                state = (next, T1)      
            
                if !haskey(cost, state) || new_cost < cost[state]               # If the point has not been evaluated already or if the cost that we calculted is better than the actual, we make some updates
                    cost[state] = new_cost                                      # Update of the cost for this state
                    frontier[state] = new_cost + h(A, next)                     # Update of the frontier
                    path[state] = (current, t)                                  # Update of the path
                end     
            end
        end
        
        current_AMR.arrivalTime = t                                             # Update the time at which the AMR arrives

        if final === nothing                                                    # The goal hasn't been reached
            error("Aucun chemin trouvé pour l'AMR $(current_AMR.id)")           # Return an error and stop the program if no solution has been found for this AMR
        end
        updatePath!(current_AMR, path, impossibleMvmt, map, docks)              # Update the path of the AMR with the solution, impossibleMvmt will also be updated at the same time
        push!(amrSol, current_AMR)                                              # Adding this AMR to the solution
        endTime = max(t,endTime)                                                # Update the endTime, which will be either the actual ending time, or the ending time of this AMR if it is greater than the actual one.
    end
        
    endT = time_ns()
    return SolutionAMR(map,amrSol, endTime, (endT-startT)/1e9)
end
