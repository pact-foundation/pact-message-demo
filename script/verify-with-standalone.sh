#!/bin/bash

# Code that does the equivalent of the following would be written in the native language, and exposed
# using the native language's task API (eg maven, gradle)

set +e
# start the producer proxy app
rackup -p 9393 provider-interface.ru &
pid=$!
sleep 2 # replace this with polling to ensure the proxy app is up
# Call the provider verifier with the URL of the proxy app
# PACT_EXECUTING_LANGUAGE needs to be set so that Ruby specific output is hidden
PACT_EXECUTING_LANGUAGE=something ./pact/bin/pact-provider-verifier message-pact.json --provider-base-url=http://localhost:9393
kill -9 $pid # shutdown the proxy app afterwards, making sure errors are handled properly!
