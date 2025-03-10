# Mimir Fly.io Demo

An example implementation deploying Grafana Mimir to Fly.io

## Explainer

### High availability

Fly.io highly recomends to "Always run at least two volumes per app." and
volumes map 1-to-1 to machines in the Fly.io architecture. This means your
minimum viable deployment of Mimir needs to have at least two instances. So for
this demo I have chosen a horizontally scaled monolith-mode deployment.

That said, there aren't any technical limitations preventing you from deploying
Mimir in micro-services mode. And you likely will want to for larger
deployments.

#### Consul serivce coordination

While most multi-service Mimir deployments should be able to get away with
utilising memberlist via DNS to discovery peers and coordinate themselves, I
haven't found a way to get this working with Fly.io. Instead we can use
[their managed Consul](https://fly.io/docs/flyctl/consul/) to provide service
discovery.

### S3 storage backend

Most S3 compatible storage backends can be used with Mimir to prvide effectively
unlimited data retention with resiliency guarantees.

This demo has been tested with both Cloudflare's R2 and Tigris Object Storage.
The latter being integrated directly into Fly.io.

Small expandable persistent volumes are still attached to each machine since
Mimir needs somewhere to store the indexes before they are compacted and shipped
off to the storage backend.

### Metrics for our metrics store

As of writing, Fly.io has a beta fly-metrics.io which lets us view the metrics
collected by the configuration present in your fly.toml under `[metrics]`.

### Quick debugging of Mimir

Sometimes we want to have a poke around at our Mimir instance, but it's not
accessible over the internet (and shouldn't be). We can do this using the handy
`fly proxy` command. Running `fly proxy 8080:8080 <your app name>.internal` will
create a wireguard tunnel making your Mimir instance now accessible on
`localhost:8080`. This is super for debugging as we can poke around at the
status dashboard here: https://localhost:8080/

## Exercise for the reader

To significantly improve the performance of Mimir, you can make use of an
external Redis for caching. Better yet, Fly.io provides managed
[Redis by Upstash](https://fly.io/docs/reference/redis/) for free. Thus you can
and should configure Mimir to use a Fly.io hosted redis instance by adding the
relevant configuration. This has been tested, but is not included in this demo
to keep things simple.

## Using `fly console`

It appears that Grafana have removed `/bin/sleep` from newer versions of the
Mimir container which causes `fly console` to fail when it tries to call `sleep
inf` on startup.

To work around this, you will need to launch the console with a different container image:

```shell
fly console --image debian
```
