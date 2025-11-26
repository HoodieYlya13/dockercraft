module github.com/docker/dockercraft

go 1.23

require (
	github.com/docker/docker v25.0.3+incompatible
	github.com/sirupsen/logrus v1.9.3
)

require (
	github.com/Microsoft/go-winio v0.4.14
	github.com/containerd/log v0.1.0
	github.com/distribution/reference v0.5.0
	github.com/docker/go-connections v0.5.0
	github.com/docker/go-units v0.5.0
	github.com/felixge/httpsnoop v1.0.4
	github.com/go-logr/logr v1.4.1
	github.com/go-logr/stdr v1.2.2
	github.com/gogo/protobuf v1.3.2
	github.com/moby/term v0.5.0
	github.com/morikuni/aec v1.0.0
	github.com/opencontainers/go-digest v1.0.0
	github.com/opencontainers/image-spec v1.0.2
	github.com/pkg/errors v0.9.1
	go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.49.0
	go.opentelemetry.io/otel v1.24.0
	go.opentelemetry.io/otel/metric v1.24.0
	go.opentelemetry.io/otel/trace v1.24.0
	golang.org/x/sys v0.1.0
	golang.org/x/time v0.5.0
	gotest.tools/v3 v3.5.1
)
