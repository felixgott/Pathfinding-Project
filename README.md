# Scientific Informatic Project
This repository contains implementations of algorithms used in the pathfinding domain. This project is supervised by X. Gandibleux, Prof. Dr. Habil. in Computer Sc. at Nantes University.  

## Repositories

### [dat](./dat)
Contains several repositories with .map files.
You'll find some real-worlds maps e.g. Paris, London or other cities streets in [street_map](./dat/street_map).
And maps from video games like [Warcraft III](./dat/dao-map/) or [Dragon Age: Origins](./dat/dao-map/).
### [doc](./doc)
*Empty for now... Coming soon...*
### [res](./res)
*Empty for now... Coming soon...*
### [src](./src)
Here you can find the source code of the project. Each file contains the algorithm of its name. 

## How to use ?

You have two ways of using the code :
1. Call the program directly in the Julia REPL. For example, you can define variables : fname *(a string which is a path to a .map file)*, S = start *(a 2-dimensional vector of Int64)*, G = goal *(a 2-dimensional vector of Int64)* in the REPL and use them like this : algoGreedy(fname, S, G) if you want to find a path from S to G in the map contained in fname with the Greedy-BFS algorithm.
2. Or you can run the main file and use the *run()* function. You will be guided to launch the execution. 

### Precisions for the inputs

We use the next call as a reference : algo(fname, S, G) where algo is either algoDijkstra or algoGreedy or algoAstar or algoBFS. Its execution is made from the root of the project.


In order to make a good call of the functions, please enter your inputs as following : 
 - **fname** : a string which represents a path that leads to a .map file. 
 - **S** and **G**    : tuples of Int64, written like follow $(x,y)$ where $x,y \in Int64$   




You will be told if either one of those points can not be reached (if it is a wall, or a tree) or if it is out of bounds.