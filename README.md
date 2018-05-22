# Finally. A Ruby Message Pact Spike.

About time, hey?

## How it works

Technically, message pact has nothing to do with HTTP, but to allow us to reuse the existing pact-provider-verifier code, and to create a langauge agnostic interface that allows the producer verification code to be written in the language of the producer itself, an HTTP producer proxy will need to be created by the pact-message author for each language.

<img src="docs/pact-message-verification-sequence-diagram.png">

## Usage

One message will pass, another will fail with the wrong content, another will fail because it can't find the producer method to call, and another will fail because it can't set up the provider state.

    script/install.sh
    script/run-with-standalone.sh

