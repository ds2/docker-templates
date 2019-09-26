# JMeter Image

To run single tests inside a container.

## How to run

Use:

    docker run -it --rm -e JMETER_FILENAME=Sync_Full.jmx -e JM_PROPS="-Jhost=host2.server.test -Juser=qotappperformancetester@server.test -Jthreads=1" -v $(pwd)/tmp:/jmeter-src -v $(pwd)/tmp/results:/jmeter-results -u $(id -u) jmeter:latest
