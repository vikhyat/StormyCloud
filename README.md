Goal
----

Make it ridiculously easy to write distributed applications in Ruby.


How it works
------------

There are only two types of entities involved: a single central server and several nodes.

The user MUST provide the following blocks of code:

- `generate`
- `perform`
- `save`

The first method, `generate` should return an array of objects, each of which corresponds to
a single task to be performed on a node. 

The second method, `perform` should accept one of the objects returned by `generate`, 
perform whatever task needs to be performed and return another object which is the output.

The last method, `save`, will be run on the server whenever a node returns a result. It 
accepts a Mutex and the output of `perform`, and should postprocess and save the result.

When a server is instantiated, it runs `generate`, serializes each task using MessagePack 
and encodes the resulting binary string into Base64, and then adds all of these tasks to a 
queue. Tasks which have already been completed (these are saved to disk) are not saved to 
this queue -- this means that the server can recover from crashes gracefully.

Upon instantiation, each node will negotiate an access token from the server and use this 
token during every future interaction with the server. This token is used so that the server
can keep track of the number of active nodes.

Each node will run a loop, repeatedly fetching tasks from the server until there are no more
tasks left. During each iteration the node fetches a task from the server, executes it and 
returns the result to the server. When a task is handed over to a node, the server moves it
to a pending array -- if the node doesn't reply within a certain time it is moved back onto
the queue.

When the node replies with the result, the server removes the task from the pending array if
it is in there. It then proceeds to check whether the task is in the list of completed tasks
 -- if it is there the result is thrown away, otherwise the result is saved and the task is 
added to the list of completed tasks which is synced onto the hard disk.

When the server is finished with all the tasks, it returns a special message to the nodes 
which causes then to exit.

