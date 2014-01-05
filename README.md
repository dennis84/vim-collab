## Usage

Run `:Collab` to start a new collab session. To join an existing session or to 
start a session with an explicit ID run `:Collab <ID>`.

Collab will continuously send patches to the socket connection, it may happen 
that one client loses the connection and the following patches can not be 
applied. To fix this run: `:CollabClean`.
