#   This file contains several functions used to treat .map files and to check several things on maps.


# Take a file with the extention ".map" in input and return a Matrix of characters that represents the map in the file.
function extractMapFromFile(file::String)
    if chopsuffix(file, ".map") != file 
        return reduce(vcat, permutedims.(collect.(readlines(file)[5:end])))
    else
        return ErrorException("Mauvais type de fichier")
    end
end

# Return true if a ∈ M, false otherwise
function isInMap(M,a)
    return size(M)[1] >= first(a) > 0 && size(M)[2] >= last(a) > 0 
end

# Return true if M[a] contains a valid character (i.e. '.' or 'S' or 'W' or 'G') 
# The case that occurs when we want to go to a 'W' cell is treated in an other function
function validChar(M,a)
    char = M[a[1],a[2]]
    return char != '@' && char != 'T' && char != 'O'
end

function possibleMovement(M,a,b)
    if isInMap(M,a) && isInMap(M,b)
        if validChar(M,b)
            if (M[b[1], b[2]] != 'W') || (M[a[1], a[2]] == 'S' || M[a[1], a[2]] == 'W')
                δx = abs(a[1] - b[1])
                δy = abs(a[2] - b[2])
                return (δx == 0 && δy == 1) || (δx == 1 && δy == 0) 
            end
        end
    end
    return false
end

function movingCost(M,a,b)
    if possibleMovement(M,a,b) 
        char = M[b[1],b[2]]
        if char == '.' || char == 'G'
            return 1
        elseif char == 'S'
            return 5
        elseif char == 'W' && (M[a[1],a[2]] == 'S' || M[a[1],a[2]] == 'W')
            return 8
        end
    else 
        return 100000 # the movement isn't possible so it returns a too big value 
    end
end

function getNeighbors(M,a::Tuple{Int64,Int64})
    i,j = a       # indexes of the point
    neighbors::Array{Tuple{Int64, Int64}} = [(i-1,j),(i+1,j),(i,j-1),(i,j+1)]
    return [b for b in neighbors if possibleMovement(M,a,b)]
end

function distance(M,a,b)
    if isInMap(M,a) && isInMap(M,b)
        return Float64(√((a[1]-b[1])^2 + (a[2]-b[2])^2))
    else
        return Float64(-1)
    end
end