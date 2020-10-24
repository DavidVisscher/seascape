# Web and Cloud Computing 2020-2021: Group 13

**David Visscher (s3278891) and Wiebe-Marten Wijnja (s2776278)**


Project: **Docker resource use measurement**


## Architecture Slides

We are hosting the architecture slides (containing elaboration on technology choices and the deployment diagram) outside of GitHub for an easy viewing/presenting experience.
You can (re)view them at [https://slides.com/qqwy/web-and-cloud-computing-group-13](https://slides.com/qqwy/web-and-cloud-computing-group-13).

## Project Requirements

### Minimal

#### Docker
All our component live inside Docker images, which are deployed (grouped in a couple of VMs) to the RUG's OpenStack cluster.

#### Docker life cycle
See the 'building docker containers' instructions later on in this README on instructions on how to transform our application code into docker containers.

#### Single Page Application
Our web-application is implemented using the [Elixir](https://elixir-lang.org/) programming language (which builds on Erlang's VM and therefore has the same multithreading/fault-tolerance features), with the [Phoenix web-framework](https://phoenixframework.org/).
For our interactive single-page application we use [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html), which is different from fully JS-based frameworks in that it:
- has transparent websocket-based two-way browser<->server communication.
- performs server-side DOM-diffing, sending the lightweight DOM changes over the websocket connection back to the user.

This means that we are able to create an SPA while writing (virtually) no JavaScript.
Only for the graphs we want to show do we hook the LiveView-state-changes into the JS chart-drawing library [`charts.js`](https://www.chartjs.org/), so we do not need to re-invent this wheel.

(c.f. [/seascape_umbrella/apps/seascape_web/assets/js](/seascape_umbrella/apps/seascape_web/assets/j) for all the JS that the project contains.)

On top of this, the full transportation layer is abstracted away, so we do not have to care about what format of serialized data needs to be transferred over the wire between browser and server.

The disadvantage of this is of course that the SPA cannot work in 'offline' mode,
but as our project requires a user to be online to fetch data from the running containers anyway, this is not a problem.

All main SPA interaction happens in the files in the [/seascape_umbrella/apps/seascape_web/lib/seascape_web/live/](/seascape_umbrella/apps/seascape_web/lib/seascape_web/live/) folder. However, it heavily leans on [/seascape_umbrella/apps/seascape_web/lib/seascape_web/state.ex](/seascape_umbrella/apps/seascape_web/lib/seascape_web/state.ex) and [its sub-modules](/seascape_umbrella/apps/seascape_web/lib/seascape_web/state) to handle the data-model stored inside the SPA.

#### Basic fault-tolerance

The web-application/SPA is able to detect that the ElasticSearch-database cluster is unreachable offline and if this is the case:
- it will display a nice message to the users that data storage and signing in is currently not possible.
- queries that would require database usage are not executed, but this does not result in application-breaking crashes but rather clear error messages to the user.

We implemented DB-facing fault-tolerance by using a circuit breaker, implemented as a watchdog Elixir process.

(c.f. [/seascape_umbrella/apps/seascape/lib/seascape/repository/elastic_search/watchdog.ex](/seascape_umbrella/apps/seascape/lib/seascape/repository/elastic_search/watchdog.ex) )

The watchdog asks the ES cluster every couple of seconds if it is healthy.
If ES responds an 'unhealthy' response (or no response at all) it is immediately considered 'bad'.
When the DB-cluster is unhealthy, we use incremental backoff with jitter to continue asking the DB for its status.
If the DB-cluster then finally responds with a 'healthy' response, we wait for a couple of these responses in a row to prevent a 'deadly embrace of death'.


#### Back-end / Database(s)

We are using [ElasticSearch](https://www.elastic.co/) (deployed as a 3-node cluster) as main data storage of both our user accounts and their clusters as well as all metric data obtained from those clusters.

ElasticSearch was chosen because of its strong properties to calculate averages and other statistics based on raw measurement data that is inserted.

As second database we rely on [Mnesia](http://erlang.org/doc/man/mnesia.html) which is built-in to the Elixir/Erlang VM. This is a distributed database which runs inside each of the Elixir nodes.
We use it to have persistent user sessions without having to rely on making the work of our load balancer more difficult (e.g. no need for 'sticky sessions') or relying on 'stateless' technologies like JWTs which have their own security-related drawbacks.

This distributed user-session handling is done for us by the Pow user management library. See [Pow.Store.Backend.MnesiaCache](https://hexdocs.pm/pow/Pow.Store.Backend.MnesiaCache.html) together with [Pow.Store.Backend.MnesiaCache.Unsplit](https://hexdocs.pm/pow/Pow.Store.Backend.MnesiaCache.Unsplit.html) for details (including how recovery from netsplits is handled).

### Extended for a higher grade

#### Admin Dashboard

We did not implement a separate admin dashboard ourselves, but you can look at the Phoenix LiveDashboard to see the current state of the connected Elixir cluster, as well as connect to a running Elixir application using a remote shell and start `:observer` there to have even more insight into and be able to debug the running system live.

#### Fault Tolerance

Both the Elixir web-nodes and Elixir ingest-nodes can be scaled independently to larger/smaller numbers, and all of them connect to form a large Elixir cluster with transparent message-passing between them. 

Because this runs on the Erlang VM which enforces the usage of the Actor Model everywhere, parts of the system are immediately notified of other parts going down/being unreachable and fault tolerance is handled in a localized fashion whenever possible due to the usage of Supervision Trees.

The Erlang VM gives us great guarantees: New nodes going up (incl. service discovery) and old nodes going down is handled automatically. Nodes crashing and restarting or the cluster being split in a network partition is also handled correctly and automatically.

Fault-tolerance w.r.t. the DB is handled by the 'watchdog' circuit breaker mentioned in the earlier section about 'minimal fault tolerance'.

Fault-tolerance w.r.t. the browser of a connected user is handled by Phoenix LiveView: when the connection to the web-application breaks, an error message is shown and incremental backoff + jitter is used to re-establish a websocket connection.

Fault-tolerance w.r.t. the 'Wave' metric-sending daemon is handled by asking the _daemon_ to initiate the connection. The wave daemon is also performing re-connection with incremental back-off + jitter when the connection fails.

#### Asynchronicity

It is a given from splitting our application into multiple docker containers but even more from using Elixir wich enforces the Actor Model that communication between different parts of the system is guaranteed to be asynchronous.
Furthermore, work/actions done by one user will not disrupt other users because the Elixir/Erlang VM uses pre-emptive scheduling.

#### Databases

Usage of our two databases was already detailed in the earlier section.

#### Orchestrator life-cycle

To actually perform orchestration we are using 'SaltStack'.
Locally we deploy to a couple of VMs running inside Vagrant.
For the actual production system we let Salt deploy to the RUG's OpenStack cluster.

#### Message Queues

We do _not_ have an 'explicit' message queue in our application, as we are already given many implicit message queues by the Elixir/Erlang VM: Every Elixir process has a 'mailbox' which is essentially a message queue that allows the process to handle incoming work asynchroniously and at its own pace.

Communication between Elixir nodes is fully transparent, but to make this even easier in a system with a dynamic topology we are using [Phoenix.PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) to publish-subscribe to certain 'topics of messages'. This allows us to send real-time updates of a connected cluster to all users that want these real-time updates in their web-interface right now, with a very low overhead and low development complexity.

Besides Elixir's process mailboxes, the Wave daemon _does_ locally buffer metric-events to be sent to ensure they do not get lost when a connection is temporarily broken.


## Setup and Maintenance

Here follow instructions to set up the application and its various components on your own development machine,
as well as build/maintain the final running system components.

### DB-Maintenance

When running on a new environment where there is no ElasticSearch database yet,
run the `mix seascape.create_elasticsearch_indexes` command to make sure all indexes that are used are actually available.

The reason this command is not automated inside the software of a node (e.g. on startup) is because one of the fallacies of distributed programming is that all software is homogeneous: we do not want a node running e.g. outdated software messing with the indices.

### Salt formulas

We are using some official salt formulas instead of writing all salt states ourselves.
Official formulas are sources from [the SaltStack Formulas Gitlab Organisation](https://github.com/saltstack-formulas)

Currently we're using:
 - [docker-formula v0.44.0](https://github.com/saltstack-formulas/docker-formula/tree/v0.44.0/docker)
 - [haproxy-formula v0.17.0](https://github.com/saltstack-formulas/haproxy-formula/tree/v0.17.0)

### Vagrant development environment

Setting up a local development using vagrant is possible. 
It requires a machine with a working libvirt installation and that the current user can make use of it.
Then, follow these steps:
 1. Navigate to deployment/vagrant and run `vagrant up --provider libvirt`.
 2. After this is done, you can ssh to the salt master with `vagrant ssh`.
 3. Once on the salt master, run `salt -b 1 \* state.highstate` as root. Depending on your network connection, this may take quite a while. I've also had it fail when connections drop, in that case you may need to run it again. Normally this shouldn't happen if the connection is stable.

### Building docker containers

Our server application is split in two Elixir applications.
Both of these live in the `seascape_umbrella` folder, and re-use common (domain-logic and DB-interaction) code.

To build docker containers containing these applications, 
run the `build_web.sh` and `build_ingest.sh` scripts, respectively.

## Testing

The most important thing to get right was the ingest system, as this depends on the part that we send to users.

Therefore, this is what we focused our testing efforts on.
These tests, include 
- unit-tests and stateless property-based that make sure that parsing works correctly, 
- websocket-wrapping tests to make sure authentication is done correctly
- tests talking with ElasticSearch to make sure correct data is stored.

Tests can be run by going to `seascape_umbrella/apps/seascape_ingest` and running  `mix test` there (while you have ElasticSearch running locally on the default port 9200).
