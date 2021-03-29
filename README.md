# Authorizer

## Overview
This application is about to handle one thing: Account State.

To handle this, is provided two operations:
  
  1 - Account Creation
  2 - Transaction Authorization

and some business rules for each one.

## Implementation
When application starts (`Authorizer.Application.start/2`) is spawned two child processes: `Authorizer.Queue.Subscriber` (responsible to consume from the event stream) and `Authorizer.DynamicSupervisor` with a `:one_for_one` strategy, responsible to dynamically create process Supervisors and Accounts at execution time.

When the `Subscriber` process is started, it consumes from the event stream, and for each one, calls the `Authorizer` to `run/1` that event. The `Authorizer` module then checks if operation contains violations of the business rules (actually who do this job is the `Authorizer.{Account, Transaction}.Checker`), and if no violation is found, the operation is executed and the account state is published (write_output/1).

## Design Decisions
I decided to read the file as a `Stream` to simulate a real scenario of event coming up, and consuming this event in a fake "Subscriber", which will call the application to process the event and publish the result (write account state to the output file). Instead of read all the file once, load to memory and process after that.

I have used some "features" from the conecptual Actors Model, which has your implementation in Elixir, by the `Agent` abstraction. That features allow us to have:
  - Fault Tolerance, once we have a dynamically supervisor created with a `:one_for_one` strategy for each (possibly) Account created;
  - Guarantee the Immutability of Account state
  - Keep Account state isolated from other process/agents/actors (do not share memory)
  - Decrease coupling 
  - Enable as to not use any external database (like the challenge rule) and an explicit in-memory structure (`%Authorizer.Account{}`)

## Installation
