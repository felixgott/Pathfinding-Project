const nbAMR = 6
# complexAMR.dat ≔ 6
# normalAMR.dat ≔ 5
# simpleAMR.dat ≔ 2
const palette = distinguishable_colors(nbAMR, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)

function amrToCol(amr::AMR)             # Used for the path 
    return palette[((amr.id - 1) % length(palette)) + 1]
end

function amrHeadToCol(amr::AMR)         # Used for the actual position of the AMR
    rgb = amrToCol(amr)
    return RGB((red(rgb) * (amr.id) /5) , (green(rgb) * (amr.id) /5 ) ,(blue(rgb) * (amr.id)/5) )
end

function charToRGB(c::Char)             # Used for converting the map (matrix of characters) into a matrix of RGB   
    if     c == '@' return RGB(0,0,0)
    elseif c == '.' return RGB(1,1,1)
    elseif c == 'S' return RGB(0.5,0.5,0.5)
    else            return RGB(1,0,0)
    end
end

function saveSol(sol::SolutionAMR, docks::Vector{Dock})
    maps = Vector{Tuple{Matrix{RGB},String,String}}()              # A vector that stores all the maps, one for each unit of time.

    for t in 1:sol.endTime
       push!(maps, instantToMatrix(sol,t, docks))
    end
    return maps
end


function instantToMatrix(sol::SolutionAMR, t::Int64, docks::Vector{Dock})      # Convert datas of the solution with a time t to a Matrix of RGB that can be plot 
    # Creating the title and the legend 
    title = "t = $t  "
    label = "Legend : \n Black square : wall     White square : ground    Gray square : slow section \n"
    for amr in sol.amrs
        dest = idDockToPoint(amr.goalDock, docks)
        label = label * "AMR$(amr.id) destination : dock $(amr.goalDock) (location : ($(dest.x),$(dest.y)) \n"
        if amr.departureTime <= t
            title = title * "AMR$(amr.id) : $(amr.path[min(t - amr.departureTime + 1, length(amr.path))])"
        else
            title = title * "AMR$(amr.id) : inactif  "
        end
    end
    

    m,n = size(sol.map)
    img = Matrix{RGB}(undef,m,n)

    for i in 1:m
        for j in 1:n
            img[i,j] = charToRGB(sol.map[i,j].c)
        end
    end
    
    # Hilight the path of all AMRs
    for amr in sol.amrs
        if t >= amr.departureTime
            for i in amr.departureTime:(t-1)
                idx = i - amr.departureTime + 1
                p = amr.path[min(idx, length(amr.path))]
                img[p.x, p.y] = amrToCol(amr)
            end
        end
    end

    # Hilight the actual position of all AMRs
    for amr in sol.amrs
        if t >= amr.departureTime
            p = amr.path[min(t - amr.departureTime + 1, length(amr.path))]
            img[p.x,p.y] = amrHeadToCol(amr)
        end
    end
    
    return img,title,label
end
