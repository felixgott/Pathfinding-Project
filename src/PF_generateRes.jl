function createRep(mapName::String)
    mkpath(joinpath(homedir(), "projets/pathfinding-project/res", splitext(basename(mapName))[1]))
end

function associateRGB(char::Char)
    if char == '.' return RGB(1.0, 1.0, 1.0) end
    if char == 'S' return RGB(0.2, 0.53, 0.23) end
    if char == 'W' return RGB(0.05, 0.32, 0.73) end
    if char == '@' || char == 'T' return RGB(0.1, 0.1, 0.1) end
    if char == 'D' return RGB(0.0, 1.0, 0.0) end
    if char == 'A' return RGB(1.0, 1.0, 0.0) end
    if char == 'P' return RGB(1.0, 0.0, 0.0) end
    return RGB(0.0, 0.0, 0.0)
end


function exportSolutionToPNG(instance::Instance, algoChoice ,algo::String, print::Bool)
    M = copy(instance.map)

    solution = algoChoice(instance)

    path = createPath(solution.path, instance.S, instance.G)

    for p in path
        M[p.x,p.y] = 'P'
    end

    M[instance.S.x, instance.S.y] = 'D'
    M[instance.G.x, instance.G.y] = 'A'
    
    mapColored = Matrix{RGB{Float64}}(undef, size(M))

    for i in 1:size(M)[1]
        for j in 1:size(M)[2]
            mapColored[i,j] = associateRGB(M[i,j])
        end
    end

    mapName = splitext(basename(instance.name))[1]
    dir_path = joinpath(homedir(), "projets/pathfinding-project/res", mapName)
    mkpath(dir_path)

    file_path = joinpath(dir_path, "fig-$(mapName)-$(algo).png")
    
    save(file_path, mapColored)

    s = "Distance D → A : $(solution.length)\n"
    s = s * "Number of states evaluated : $(solution.nbStates)\n"
    s = s * "Path D → A : $(pathToString(path))\n"
    s = s * "Computing time : $(solution.tElapsed) sec.\n"
    
    if print 
        println(s)
    end

    file_path = joinpath(dir_path, "res-$(mapName)-$(algo).txt")
    
    write(file_path, s)
end

function exportResAll(instance::Instance, print::Bool)
    exportSolutionToPNG(instance, algoAstar,    "aStar",    print)
    exportSolutionToPNG(instance, algoDijkstra, "Dijkstra", print)
    exportSolutionToPNG(instance, algoBFS,      "BFS",      print)
    exportSolutionToPNG(instance, algoGreedy,   "Greedy",   print)
end

function exportRes(instance::Instance, algo, algoStr, print::Bool)
    exportSolutionToPNG(instance, algo, algoStr, print)
end