# Kiddler

**Web and HTTP Debugging and Troubleshooting in Kubernetes Made Simple**

## Use Cases

### Capture Traffic to Inspect Request/Response Details

Follow these steps to capture and analyze HTTP traffic in your Kubernetes environment:

#### STEP 1: Add the Kiddler Container to Your Pod
Insert the Kiddler container definition into your existing pod spec:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: existing-pod
  labels:
    app: my-app
spec:
  containers:
  - name: existing-container
    image: your-existing-image:tag  # Your original application container
  - name: kiddler
    image: ghcr.io/awesomedog/kiddler:latest
    ports:
    - containerPort: 80        # HTTP endpoints (for httpbin-like debugging)
    - containerPort: 8001      # Traffic capture proxy port
```

#### STEP 2: Proxy Traffic to Kiddler
Configure your service (e.g., Nginx) to route traffic through Kiddler's proxy port (`8001`) for inspection:

```conf
# Example Nginx configuration snippet
location /whatever {
    proxy_pass http://127.0.0.1:8001/;  # Route traffic through Kiddler
}
```

#### STEP 3: Access Traffic Details
Inspect captured request/response data through any of these methods:

- Kiddler container's standard output (stdout)
- Log file inspection: `tail -f /var/log/supervisor/nginx.err.log`
- Web access: `http://127.0.0.1/debug/logs/nginx.err.log`

### Debug Connectivity with HTTP Endpoints
Kiddler exposes a subset of `httpbin`-compatible endpoints on port `80` to validate connectivity, headers, and request handling:

- [`/absolute-redirect/:n`](/absolute-redirect/6) 302 Absolute redirects *n* times.
- [`/anything/:anything`](/anything) Returns anything that is passed to request.
- [`/base64/:value?content-type=ct`](/base64/eyJzZXJ2ZXIiOiAiZ28taHR0cGJpbiJ9Cg==?content-type=application/json) Decodes a Base64-encoded string, with optional Content-Type.
- [`/base64/decode/:value?content-type=ct`](/base64/decode/aHR0cGJpbmdvLm9yZw==) Explicit URL for decoding a Base64 encoded string.
- [`/base64/encode/:value`](/base64/encode/httpbingo.org) Encodes a string into URL-safe Base64.
- [`/basic-auth/:user/:password`](/basic-auth/user/password) Challenges HTTPBasic Auth.
- [`/bearer`](/bearer) Checks Bearer token header - returns 401 if not set.
- [`~~/brotli~~`](/brotli) Returns brotli-encoded data. *Not implemented!*
- [`/bytes/:n`](/bytes/1024) Generates *n* random bytes of binary data, accepts optional *seed* integer parameter.
- [`/cache`](/cache) Returns 200 unless an If-Modified-Since or If-None-Match header is provided, when it returns a 304.
- [`/cache/:n`](/cache/60) Sets a Cache-Control header for *n* seconds.
- [`/cookies`](/cookies) Returns cookie data.
- [`/cookies/delete?name`](/cookies/delete?k1=&k2=) Deletes one or more simple cookies.
- [`/cookies/set?name=value`](/cookies/set?k1=v1&k2=v2) Sets one or more simple cookies.
- [`/deflate`](/deflate) Returns deflate-encoded data.
- [`/delay/:n`](/delay/3) Delays responding for *min(n, 10)* seconds.
- `/delete` Returns request data. Allows only `DELETE` requests.
- [`/deny`](/deny) Denied by robots.txt file.
- [`/digest-auth/:qop/:user/:password`](/digest-auth/auth/user/password) Challenges HTTP Digest Auth using default MD5 algorithm
- [`/digest-auth/:qop/:user/:password/:algorithm`](/digest-auth/auth/user/password/SHA-256) Challenges HTTP Digest Auth using specified algorithm (MD5 or SHA-256)
- [`/drip?numbytes=n&duration=s&delay=s&code=code`](/drip?code=200&numbytes=5&duration=5) Drips data over the given duration after an optional initial delay, simulating a slow HTTP server.
- [`/dump/request`](/dump/request) Returns the given request in its HTTP/1.x wire approximate representation.
- [`/encoding/utf8`](/encoding/utf8) Returns page containing UTF-8 data.
- [`/env`](/env) Returns all environment variables named with `HTTPBIN_ENV_` prefix.
- [`/etag/:etag`](/etag/etag) Assumes the resource has the given etag and responds to If-None-Match header with a 200 or 304 and If-Match with a 200 or 412 as appropriate.
- [`/forms/post`](/forms/post) HTML form that submits to */post*
- [`/get`](/get) Returns GET data.
- [`/gzip`](/gzip) Returns gzip-encoded data.
- `/head` Returns response headers. Allows only `HEAD` requests.
- [`/headers`](/headers) Returns request header dict.
- [`/hidden-basic-auth/:user/:password`](/hidden-basic-auth/user/password) 404'd BasicAuth.
- [`/html`](/html) Renders an HTML Page.
- [`/hostname`](/hostname) Returns the name of the host serving the request.
- [`/image`](/image) Returns page containing an image based on sent Accept header.
- [`/image/jpeg`](/image/jpeg) Returns a JPEG image.
- [`/image/png`](/image/png) Returns a PNG image.
- [`/image/svg`](/image/svg) Returns a SVG image.
- [`/image/webp`](/image/webp) Returns a WEBP image.
- [`/ip`](/ip) Returns Origin IP.
- [`/json`](/json) Returns JSON.
- [`/links/:n`](/links/10) Returns page containing *n* HTML links.
- `/patch` Returns request data. Allows only `PATCH` requests.
- `/post` Returns request data. Allows only `POST` requests.
- `/put` Returns request data. Allows only `PUT` requests.
- [`/range/1024?duration=s&chunk_size=code`](/range/:n) Streams *n* bytes, and allows specifying a *Range* header to select a subset of the data. Accepts a *chunk_size* and request *duration* parameter.
- [`/redirect-to?url=foo&status_code=307`](/redirect-to?status_code=307&url=http%3A%2F%2Fexample.com%2F) 307 Redirects to the *foo* URL.
- [`/redirect-to?url=foo`](/redirect-to?url=http%3A%2F%2Fexample.com%2F) 302 Redirects to the *foo* URL.
- [`/redirect/:n`](/redirect/6) 302 Redirects *n* times.
- [`/relative-redirect/:n`](/relative-redirect/6) 302 Relative redirects *n* times.
- [`/response-headers?key=val`](/response-headers?Server=httpbin&Content-Type=text%2Fplain%3B+charset%3DUTF-8) Returns given response headers.
- [`/robots.txt`](/robots.txt) Returns some robots.txt rules.
- [`/sse?delay=1s&duration=5s&count=10`](/sse?delay=1s&duration=5s&count=10) a stream of server-sent events.
- [`/status/:code`](/status/418) Returns given HTTP Status code.
- [`/stream-bytes/:n`](/stream-bytes/1024) Streams *n* random bytes of binary data, accepts optional *seed* and *chunk_size* integer parameters.
- [`/stream/:n`](/stream/20) Streams *min(n, 100)* lines.
- [`/trailers?key=val`](/trailers?trailer1=value1&trailer2=value2) Returns JSON response with query params added as HTTP Trailers.
- [`/unstable`](/unstable) Fails half the time, accepts optional *failure_rate* float and *seed* integer parameters.
- [`/user-agent`](/user-agent) Returns user-agent.
- [`/uuid`](/uuid) Generates a [UUIDv4](https://en.wikipedia.org/wiki/Universally_unique_identifier) value.
- [`/websocket/echo?max_fragment_size=2048&max_message_size=10240`](/websocket/echo?max_fragment_size=2048&max_message_size=10240) A WebSocket echo service.
- [`/xml`](/xml) Returns some XML

### Run Commands in the Container
Access an interactive Ubuntu bash shell via:  
[`/debug/ttyd`](/debug/ttyd)  

### View Real-Time Logs
Browse up-to-date container logs at:  
[`/debug/logs`](/debug/logs)  

### View This Documentation
Access this help file directly in the container at:  
[index page `/`](/)  


## For Developers

### Local Development Workflow

1. Do whatever edits

2. Build a test image:
   ```bash
   docker build -t test .
   ```

3. Run the container with port mapping:
   ```bash
   docker run -it -p 80:80 -p 8001:8001 test /bin/bash
   ```

4. Start the supervisor process (manages services):
   ```bash
   supervisord &
   ```
