+++
title = "Don't brick your NixOS, use preSwitchChecks"
date = 2026-06-28

[taxonomies]
tags = ["nixos"]

[extra]
repo_view = true
comment = true
+++

## Problem Statement

I've recently deployed a fair amount of new public-facing services to one of my NixOS hosts. While experimenting with Traefik and Anubis configuration, I accidentaly brought this blog down for a couple minutes. No biggie, the SLA is best-effort after all 😁. Even so, I started wondering if there's any way to hook a healthcheck into the NixOS rebuild process. For example, I would like my deploy process to fail during `nixos-rebuild test`, if any of the attached probes have failed. 

## Solution 

A friend recommended trying [system.preSwitchChecks](https://mynixos.com/nixpkgs/option/system.preSwitchChecks) ([src](https://github.com/NixOS/nixpkgs/blob/8c91a71d13451abc40eb9dae8910f972f979852f/nixos/modules/system/activation/pre-switch-check.nix)), which was exactly what I needed. Given that the documentation is a bit cryptic for my taste, here's a simple example demonstrating one possible use case.

Before we dive into it, here's an outline of the system at hand:
- the blog is a statically generated site, served on `localhost` by nginx.
- The nginx server is reverse proxied to the open Internet by Traefik, which:
  - handles TLS termination,
  - introduces a bunch of fun middlewares into the mix.

### Implementation

```nix
{ config, pkgs, ...}:
{
  system.preSwitchChecks = {
    blogLocalhostNoHttpError = ''
      ${pkgs.curl}/bin/curl \
        --fail-with-body \
        --silent \
        --show-error \
          http://127.0.0.1:${toString config.sp6catVm01.ports.blog} \
        >/dev/null
    '';

    blogDomainBlocksScrape = ''
      response=$(${pkgs.curl}/bin/curl \
        --silent \
        --write-out "%{response_code}" \
        --follow \
          https://${config.globals.baseDomain})

      if [[ "$response" != *Anubis* ]]; then
          echo "Expected the response to contain 'Anubis', got $response"
      fi

      if [[ ! "$response" =~ 403$ ]]; then
          echo "Expected 403 response code, got \$\{response\}"
      fi
    '';
  };
}
```

Let's decompose this Nix config:

- `blogLocalhostNoHttpError` asserts that the local nginx server is responding and successfully serving the website. 
  - If nginx was down or otherwise not listening on the expected address, curl would fail to establish a TCP connection, with an exit with code `7` ([doc](https://curl.se/docs/manpage.html#--fail-with-body:~:text=Failed%20to%20connect%20to%20host%2E)). inb4 "`nixos-rebuild test` will fail if nginx fails to start" - yes, but I might unintentionally disable the service, in which case the `test` would pass, if not for this check.
  - If nginx was responding, but lacking the statically generated site files, or was otherwise misconfigured, it would likely respond with a `HTTP 404` or other code equal or greater than `HTTP 400`. Thanks to the `--fail-with-body` option, curl will fail with an exit code `22` ([doc](https://curl.se/docs/manpage.html#--fail-with-body:~:text=HTTP%20page%20not%20retrieved%2E%20The%20requested%20URL%20was%20not%20found%20or%20returned%20another%20error%20with%20the%20HTTP%20error%20code%20being%20400%20or%20above%2E%20This%20return%20code%20only%20appears%20if%20%2D%2Dfail%20is%20used%2E)).
- `blogDomainNoHttpError` queries the blog, as seen by the end user, exercising the Traefik reverse proxy path. 
  - Traefik gates the service with [Anubis](https://github.com/TecharoHQ/anubis) through a [forwardAuth](https://doc.traefik.io/traefik/reference/routing-configuration/http/middlewares/forwardauth/) middleware, hence a plain curl request will (should) result with the response being a `HTTP 403`. Just to be sure, I also scan the response body for the `Anubis` keyword.
  - This check will also fail in the case of a domain resolution failure, catching a potential DNS zone misconfiguration.

These `preSwitchChecks` are definitely not bullet-proof, but they cover the most probable failure modes, without getting too much into the weeds. With more complex services, you'll want to make the healthchecks appropriately nuanced, in order to avoid a watermelon outcome - green to the eye, but red inside (should fail, but didn't).

Here's how failing to pass one of the checks would manifest during `nixos-rebuild test`:

```sh
building the system configuration...
curl: (7) Failed to connect to 127.0.0.1 port 2222 after 0 ms: Could not connect to server
Pre-switch check 'blogLocalhostNoHttpError' failed
Pre-switch checks failed
```

### Possibilities

Here's a bunch of other `preSwitchChecks` applications, off the top of my mind:

- Ensure a volume is mounted at a given path. 
- Ensure if hostname or IP address (static) haven't changed.
- Ensure a kernel module is (or is not) loaded.
- Ensure a host is (or is not) reachable.

### Conclusion

Use `preSwitchChecks`, they're easy to use and might save you some grief. 
