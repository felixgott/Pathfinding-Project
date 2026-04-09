using DataStructures        # For PriorityQueue
ENV["GKSwstype"] = "100"
using Plots, Images, Colors # For graphics

# Import all files
include("AMR_datastructures.jl")
include("AMR_tools.jl")
include("AMR_Astar.jl")
include("AMR_display.jl")


function main()
    filename = "smallAMR.dat"             # change this string if you want another file. It has to be located in the res/AMR_data repository

    amrs, docks, trucks, map = parse_file("dat/AMR_data/$filename")    # parsing the file
    instance = InstanceAMR(map, docks, amrs, trucks)                    # make the datas into an instance
    sol = astarAMR(instance)                                            # solving the instance
    sort!(sol.amrs, by = x -> x.id)                                     # sort the AMR vector for better displaying
    maps = saveSol(sol, docks)                                          # save a map for each unit of time
    
    display = true      # true → output results in the res repository / false → output nothing
    saveRes = true     # true → saving png files for each time / false → saving nothing
    keepRes = true      # true → printing and saving results in both the repository and the terminal / false → printing and saving nothing

    dirname = splitext(filename)[1]

    if keepRes
        s = "Results of the computation : \n
            Results obtained in $(sol.tElapsed) seconds \n
            All AMRs are at destination at time  t = $(sol.endTime)\n"
        for amr in sol.amrs                 # saving each AMR datas
            s = s * "AMR n°$(amr.id) : \n Departure time : $(amr.departureTime) at dock n°$(amr.startingDock)\n Arrival time   : $(amr.arrivalTime) at dock n°$(amr.goalDock)\n"
            s = s * "Path : "
            for p in amr.path               #  saving AMR's path
                s = s * "(" * string(p.x) * "," * string(p.y) * ") →  "
            end  
            s = s * "Arrived ! \n"
        end

        println(s)
     
        mkpath("res/$dirname")                 # create the repository if it doesn't exist
        touch("res/$dirname/results.txt")      # create the file to save the results
        write("res/$dirname/results.txt",s)    # saving the results
    
    end

    if display
        mkpath("res/$dirname")                 # create the repository if it doesn't exist

        t = 1
        p = plot(layout = grid(1, 2, widths=[0.6,0.4]),    # Creating a canva
                    size = (1920,1080))

        scatter!(p[2],[], [],                              # Add legend
                    label = maps[1][3], 
                    color = :black, 
                    markerstrokewidth = 0, 
                    subplot = 2,
                    legend = :topleft,
                    legendfontsize = 10,
                    framestyle = :none,
                    ticks = false
                    )
        for (map,title,label) in maps                       # ploting each map of the maps   

            plot!(p[1],map,                                 # plot the map
                seriestype = :image, 
                ticks = false, 
                framestyle = :box, 
                title = title,
                titlefontsize = 10,
                subplot = 1)                               
                  
            
            savefig(p,"res/$dirname/time$t.png")       # Saving the image    
            t+=1    
        end
        

        dir = "res/$dirname"
        files = filter(f -> endswith(f, ".png") && startswith(f, "time"), readdir(dir))     # collect files that correspond to map at different times
        sort!(files, by = x -> parse(Int, replace(x, r"[^\d]" => "")))                      # sort the files by order of the time, the regex delete the parts that are not numbers
        files = joinpath.(dir,files)                                                        # add the path to the file    

        anim = @animate for f in files                                                      # Create the gif with all the times
            img = load(f)                                               
            plot(img, axis=false, ticks=false, aspect_ratio=:equal, dpi = 300)                         
        end

        gif(anim, "$dir/anim.gif", fps = 3)                                                 # save the GIF
        
        
        if !saveRes                                                                         # if saveRes is false, we delete the files, except for the gif and the output results
            println("Deleting the pdf files...")
            for t in 1:sol.endTime
                rm("res/$dirname/time$t.png")
            end
        end
        println("Done ✓")
    end
    
end