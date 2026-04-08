include("PF_datastructure.jl")
include("PF_generateRes.jl")
include("PF_tools.jl")
include("PF_algos.jl")

using DataStructures
using Images
using REPL.TerminalMenus

function main()

    all = true         # switch to false to choose the algorithm
    printing = false   # switch to enable the printing of the computanional results of the solution in the terminal

    println("Please enter a path to a file that end with .map : ")
    fname::String = replace(readline(), '"' => "")
    D = enterCoordinates("Enter the coordinates for the start with integers values in the format x,y : ")
    A = enterCoordinates("Enter the coordinates for the goal with integers values in the format x,y: ")

    if isfile(fname) 
        instance = Instance(fname, extractMapFromFile(fname), D, A)

        if all 
            println("Exporting the results of the computations with PNGs to $(joinpath("pathfinding-project/res",splitext(basename(fname))[1]))...")
            exportResAll(instance, printing)
            println("All done ✓")
        else
            # (algo,algoStr) = chooseAlgo("Please enter a number between 0 and 3 in order to choose an algorithm as follow : 
            # \n- 0 for the A* algorithm \n- 1 for the greedy-BFS algorithm \n- 2 for the Dijkstra algorithm \n- 3 for the BFS algorithm \n- Anything else will end the program")
            (algo,algoStr) = chooseAlgo()

            if algo == "quit"
                println("Closing the program...")
                return
            else 
                println("Exporting the results of the computation with PNG to $(joinpath("pathfinding-project/res",splitext(basename(fname))[1]))...")
                exportRes(instance, algo, algoStr, printing)
                println("Done ✓")
            end
        end
    end

end

function enterCoordinates(message::String)
    println(message)

    input = readline()

    while true
        parts = split(replace(input, r"[() ]" => ""), ",")
        if length(parts) == 2 
            x = tryparse(Int64, parts[1])
            y = tryparse(Int64, parts[2])
            if !isnothing(x) && !isnothing(y)
                return Point(x,y)
            else
                println("Wrong input, please retry : ")
                input = readline()
            end
        end
    end
end


function chooseAlgo()
    menu = RadioMenu(["Astar", "Greedy", "Dijkstra", "BFS", "Quitter"])
    choice = request("Chose your algorithm :", menu)
    
    algos = [algoAstar, algoGreedy, algoDijkstra, algoBFS]
    algosStr = ["Astar", "Greedy", "Dijkstra", "BFS"]
    if choice <= 4
        return algos[choice], algosStr[choice]
    else
        return nothing
    end
end