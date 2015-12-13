# elixir-load-balancer
Joe Thelen and Henry Fellows  
It's a (mostly) automatic paralleling load system, like map/reduce, but even more magic.

##Goals:
- Efficiently allocate work to an arbitrary number of nodes to complete computations.
- Automatically "bring up" and "shut down" nodes (elixir instances)
- Distribute work based on node capabilities.
- File IO for data input and output, config files, etc.

##Architecture:
- Single master node
- Multiple worker nodes

##Distributing Work:
####Nodes
- Node performance is represented by a single composite score.
  - For now, this score is ``(# of CPUs) * (GB of RAM)``
  - In the future we can change how this score is generated.
- Each node is assumed to have a maximum number of workers that it can effectively run. This number is currently assumed to be ``3 * (# of CPUs)``
- Each node has a minimum amount of RAM (as a % of total system RAM) per worker based on its maximum number of workers and total RAM.

####Workers
A worker is an individual elixir process which does a piece of work and returns a result to its master. It is a module that has the name ``worker`` and the modules ``mapper`` and ``reducer``. The exact behaviors of ``mapper`` and ``reducer`` are decided at compilation; they are loaded from the first file in ``/workers``. Each contains the function ``start`` If the file in ``/workers`` is missing, or does not contain both a ``mapper`` and ``reducer`` function, a fatal exception will be thrown. 

#####mapper
- the results of mapper cannot be dependent on side-effecting behaivor. 
- mapper.start takes a file name as a string, and two line numbers.
- mapper.start reads, and performs a calculation on the data contained between those two line numbers.
- mapper.start return behavor unspecified.

#####reducer
- the results of mapper cannot be dependent on side-effecting behavior. 
- reducer.start takes a list of the return values of ``mapper``.
- reducer.start must be associative, idempotent, and free of side effects.
- reducer.start returns a single element in the same format as ``mapper``.

for example, a program that counts number of differently colored birds:
```
  reducer.start([{:blue 2, :red 4, :black 5} {:blue 7, brown 3} {:black 6}])
  should return
{:blue 9, :red 4, :black 11, :brown 3}
```
##Config Files:
####Work Configuration File
- List of raw data files to be used.

####Hosts Configuration File
- List of available hosts
- Information about performance of individual hosts

##Data Files:
####Raw data files
- put in ``/data``
- smallest quantum of work must be on individual lines.

####Mapper & Reducer code
- put in ``/worker``
- files named ``mapper.ex`` and ``reducer.ex``
