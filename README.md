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
####Node Performance
- Node performance is represented by a single composite score.
  - For now, this score is ``(# of CPUs) * (GB of RAM)``
  - In the future we can change how this score is generated.

####Workers
A worker is an individual elixir process which does a piece of work and returns a result to its master.

- Each node is assumed to have a maximum number of workers that it can effectivly run. This number is currently assumed to be ``3 * (# of CPUs)``

- Each node has a minimum amount of RAM (as a % of total system RAM) per worker based on its maximum number of workers and total RAM.

##Config Files:
####Work Configuration File
- List of raw data files to be used.
- 

####Hosts Configuration File
- List of available hosts
- Information about performance of individual hosts


