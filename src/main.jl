include("algoAstar.jl")
include("algoBFS.jl")
include("algoDijkstra.jl")
include("algoGreedy.jl")
include("map.jl")

using DataStructures

function run()
    println("Please enter a filename which end with .map : ")
    fname::String = replcae(readline(), '"', "")
    D = enterCoordinates("Enter the coordinates for the start with integers values in the format x,y : ")
    A = enterCoordinates("Enter the coordinates for the goal with integers values in the format x,y: ")

    algo = chooseAlgo("Please enter a number between 0 and 3 in order to choose an algorithm as follow : 
    \n- 0 for the A* algorithm \n- 1 for the greedy-BFS algorithm \n- 2 for the Dijkstra algorithm \n- 3 for the BFS algorithm \n- Anything else will end the program")

    if algo == "quit"
        println("Closing the program...")
        return
    else 
        algo(fname, D, A)
    end
end

function enterCoordinates(message::String)
    println(message)

    input = readline()
    
    (x,y) = Tuple{Int64,Int64}((-1,-1))

    while true
        parts = split(replace(input, r"[() ]" => ""), ",")
        if length(parts) == 2 
            x = tryparse(Int64, parts[1])
            y = tryparse(Int64, parts[2])
            if !isnothing(x) && !isnothing(y)
                return (x,y)
            else
                println("Wrong input, please retry : ")
                input = readline()
            end
        end
    end
end

function chooseAlgo(message::String)
    println(message)

    algos = Dict{String,Any}(
        "0" => algoAstar,
        "1" => algoGreedy,
        "2" => algoDijkstra,
        "3" => algoBFS,
    )
    
    while true
        input = strip(readline())
        
        if haskey(algos, input)
            return algos[input]
        else
            return "quit"
        end
    end
end
