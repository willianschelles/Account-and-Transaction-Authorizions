# Authorizer

## Overview
This application is about to handle one thing: Account State.

To handle this, is provided two operations:
  
  - Account Creation
  - Transaction Authorization

and some business rules for each one.

## Implementation
When application starts (`Authorizer.Application.start/2`) is spawned two child processes: `Authorizer.Queue.Subscriber` (responsible to consume from the event stream) and `Authorizer.DynamicSupervisor` with a `:one_for_one` strategy, responsible to dynamically create process Supervisors and Accounts at execution time.

When the `Subscriber` process is started, it consumes from the event stream, and for each one, calls the `Authorizer` to `run/1` that event. The `Authorizer` module then checks if operation contains violations of the business rules (actually who do this job is the `Authorizer.{Account, Transaction}.Checker`), and if no violation is found, the operation is executed and the account state + violations is published (write_output/1).

**note**: Has a simplified application flow in PDF attached.

## Design Decisions
I decided to read the file as a `Stream` to simulate a real scenario of event coming up, and consuming this event in a fake "Subscriber", which will call the application to process the event and publish the result (write account state + violations to the output file). Instead of read all the file once, load to memory and process after that.

I have used some "features" from the conecptual Actors Model, which has your implementation in Elixir, by the `Agent` abstraction. That features allow us to have:
  - Fault Tolerance, once we have a dynamically supervisor created with a `:one_for_one` strategy for each (possibly) Account created;
  - Guarantee the Immutability of Account state
  - Keep Account state isolated from other process/agents/actors (do not share memory)
  - Decrease coupling 
  - Enable as to not use any external database (like the challenge rule) and an explicit in-memory structure (`%Authorizer.Account{}`)
  - Decrease coupling 
 
## Installation and Running

Once the application is dockerized, we need to:

`$ docker build -t authorizer .`

`$ docker run -it authorizer /bin/sh`

and then, to run tests:

`/opt $ MIX_ENV=test mix test`

to run application:

`/opt $ MIX_ENV=dev mix run`

to read from output file with state account + violations:

`/opt $ cat output`


**note**: * the lib I am using to decode / encode the json file is using some deprecated function and, due to this, some `Warnings` are appearing in the output when compiling the application, I saw this late, unfortunately *
