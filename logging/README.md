# Application logging notes

Container logs should be directed to container `STDOUT` and `STDERR` if you want to retrieve them using `docker logs` and `docker service logs` CLI commands or view in Docker Enterprise UCP console.

If the application uses one of common logging libraries that have pluggable appenders/tracers (e.g. log4net, Enterprise Library Logging etc.), a simple way to forward the logs to `STDOUT/STDERR` is to write them to a file or a Windows EventLog inside of the container, and then read the log entries with a simple powershell script. The script, in its turn, should post the log entries to `STDOUT/STDERR` of the container.
If a less privileged account is used to run ASP.NET application pool (i.e. other than `LocalSystem`), make sure to create the **event source** for you application logs that will be used to write log entries into the EventLog, and set `EventMessageFile` key so that log entries are handled properly in the EventLog.
See `Dockerfile`s at [mvc-log4net/src](./mvc-log4net/src/) example app for more details.
