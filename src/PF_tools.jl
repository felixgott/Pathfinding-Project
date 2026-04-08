#   This file contains several functions used to treat .map files and to check several things on maps.


# Take a file with the extention ".map" in input and return a Matrix of characters that represents the map in the file.
function extractMapFromFile(file::String)
    if chopsuffix(file, ".map") != file 
        return reduce(vcat, permutedims.(collect.(readlines(file)[5:end])))
    else
        return ErrorException("Mauvais type de fichier")
    end
end

function possibleMovement(M,a::Point,b::Point)
    if isInMap(M,a) && isInMap(M,b)
        if validChar(M,b)
            if (M[b.x, b.y] != 'W') || (M[a.x, a.y] == 'S' || M[a.x, a.y] == 'W')
                δx = abs(a.x - b.x)
                δy = abs(a.y - b.y)
                return (δx == 0 && δy == 1) || (δx == 1 && δy == 0) 
            end
        end
    end
    return false
end

function isInMap(M,a::Point)
    return size(M)[2] >= a.y > 0 && size(M)[1] >= a.x > 0 
end


function movingCost(M,a::Point,b::Point)
    char = M[b.x,b.y]
    if char == '.' || char == 'G'
        return 1
    elseif char == 'S'
        return 5
    elseif char == 'W' && (M[a.x,a.y] == 'S' || M[a.x,a.y] == 'W')
        return 8
    else
        return 100000
    end
end

function getNeighbors(M,a::Point)
    i,j = a.x,a.y       # indexes of the point
    neighbors::Array{Point} = [Point(i-1,j),Point(i+1,j),Point(i,j-1),Point(i,j+1)]
    return [b for b in neighbors if possibleMovement(M,a,b)]
end

function distance(M,a,b)
    if isInMap(M,a) && isInMap(M,b)
        return Float64(abs(a.x-b.x) + abs(a.y-b.y))
    else
        return Float64(-1)
    end
end

function validInstance(instance::Instance)
    map,S,G = instance.map, instance.S, instance.G

    if !isInMap(map,S) || !isInMap(map,G)
        throw(ArgumentError("One of those point is not in the map"))
        return false
    elseif !validChar(map,S) || !validChar(map,G)
        throw(ArgumentError("One of those point can't be reached"))
    else
        return true
    end
end


function validChar(M,a)
    char = M[a.x,a.y]
    return char != '@' && char != 'T' && char != 'O'
end


function createPath(path::Dict{Point, Point}, start::Point, goal::Point)
    path_list::Vector{Point} = Point[]
    current = goal

    while current != start 
        push!(path_list,current)
        if !haskey(path, current)
            error("Erreur lors de la reconstruction du chemin")
        end
        current = path[current]
    end

    push!(path_list, start)
    reverse!(path_list)

    return path_list
end

function pathToString(path::Vector{Point})
    return join([string((p.x, p.y)) for p in path], " → ")
end