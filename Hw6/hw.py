"""
- Need at least 1 client
+ Need 5 servers, each with its own port 
+ Establish relationship among the 5 servers 
- Define the 2 commands: IAMAT and WHATSAT
	- Execute the commands using the Google Places API
	- Format the response from the server
- Parse invalid commands

- Log stuff
- CONNECT THINGS
- Clock skew
- Invalid number of args

- Doesn't have async primitive in Python
- Python multithreading (not true concurrency): Global Interpreter Lock (GIL) is a mechanism used in computer language interpreters to
synchronize the execution of threads so that only one thread can execute at a time



Node faster b/c runs on chrome v8 which does just in time compiling. therefore doesn't have to conitnually interpret code which is slow.

2 clients: 1 normal client, 1 for the servers to communicate with each other

Write a report that summarizes your research, recommends whether Twisted is a suitable framework for this kind of application, 
and justifies your recommendation. Describe any problems you ran into. Your report should directly address your boss's worries 
about Python's type checking, memory management, and multithreading, compared to a Java-based approach to this problem. Your 
report should also briefly compare the overall approach of Twisted to that of Node.js, with the understanding that you probably 
won't have time to look deeply into Node.js before finishing this project.

Your research and report should focus on language-related issues. For example, how easy is it to write Twisted-based programs 
that run and exploit server herds? What are the performance implications of using Twisted? Don't worry about nontechnical issues
like licensing, or about management issues like software support and retraining programmers.

Through this project 

TO RUN:
 sed 's/1025/12019/' /u/cs/fac/eggert/src/Twisted-15.0.0/doc/_downloads/chatserver.py >chatserver.py
 twistd -n -y chatserver.py
On other terminal: connect to same server

 sed 's/1025/12019/' /u/cs/fac/eggert/src/Twisted-15.0.0/doc/_downloads/chatserver.py >chatserver.py

"""
------------------------------------------------
""" AT Alford +0.563873386 kiwi.cs.ucla.edu +34.068930-118.445127 1400794699.108893381
where AT is the name of the response, Alford is the ID of the server that got the message from the client, 
+0.563873386 is the difference between the server's idea of when it got the message from the client and the client's time stamp, 
and the remaining fields are a copy of the IAMAT data. In this example (the normal case), the server's time stamp is greater 
than the client's so the difference is positive, but it might be negative if there was enough clock skew in that direction."""


#The server responds with a AT message in the same format as before, giving the most recent location reported by the client, 
#along with the server that it talked to and the time the server did the talking. Following the AT message is a JSON-format message, 
#exactly in the same format that Google Places gives for a Nearby Search request (except that any sequence of two or more adjacent 
#newlines is replaced by a single newline and that all trailing newlines are removed), followed by two newlines. 


""" Servers should respond to invalid commands with a line that contains a question mark (?), a space, 
and then a copy of the invalid command.

Servers communicate to each other too, using AT messages (or some variant of your design) to implement a simple flooding algorithm 
to propagate location updates to each other. Servers should not propagate place information to each other, only locations; when asked 
for place information, a server should contact Google Places directly for it. Servers should continue to operate if their 
neighboring servers go down, that is, drop a connection and then reopen a connection later.

Each server should log its input and output into a file, using a format of your design. The logs should also contain notices of new 
and dropped connections from other servers. You can use the logs' data in your reports."""