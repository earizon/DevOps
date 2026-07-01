[[{reverse_proxy.telebit,security.TLS.LetsEncrypt]]
# Telebit.io: secure, end-to-end Encrypted tunnel.

* <https://github.com/therootcompany/telebit>

  ```
  | # Setup config through (DevOps friendly) Env.vars 
  | $ export            DEBUG=true # or --debug
  | $ export          VERBOSE=...  --verbose ...
  | $ export          VERBOSE_BYTES=....
  | $ export          VERBOSE_RAW=...
  | 
  | $ export       ACME_AGREE=true  
  | # or --acme-agree, agree to terms of ACME Svc provider
  | $ export ACME_EMAIL=abc@mail.com# --acme-email, email used @ LetsEncrypt
  | $ export  VENDOR_ID=abc.com    # or --vendor-id. Unique ID
  | $ export     SECRET=...device-shared-secret...
  | $ export     LOCALS=https:*:3000 # or --locals ...
  | $ export TLS_LOCALS=https:*:3000 # or --tls-locals
  | $ export TUNNEL_RELAY_URL=https://tunnel.example.com/ # ¹
  | # or --tunnel-relay-url: websocket url at which to connect to the Tu.relay
  | 
  | $ telebit # (Integrate with systemd/serviceman/... for automatic startup)
  | 
  | ¹ Other Options:
  |             /--acme-directory  : ACME Directory URL
  |             /--acme-http-01    : enable HTTP-01 ACME challenges
  |             /--acme-relay-url  : base url of ACME DNS-01 relay, if != tunnel relay
  |             /--acme-staging    : get fake certificates for testing
  |             /--acme-storage    : path to ACME storage dir. (def. "./acme.d/")
  |             /--acme-tls-alpn-01: enable TLS-ALPN-01 ACME challenges
  | API_HOSTNAME/--api-hostname    : hostname used to manage clients
  |             /--auth-url        : base url for Authentication, if != tunnel relay
  |             /--dns-01-delay    : add extra delay after DNS self-check to allow DNS-01 challenges to propagate
  |             /--dns-resolvers   : list of resolvers in format 8.8.8.8:53,8.8.4.4:53
  |             /--env             : path to .env file
  |             /--exit-after      : Ex. "12h" (forcefully exit after timeout)
  |             /--exit-at         : Ex. "15:04" (forcefully exit after time)
  |             /--leeway          : allow for time drift / skew (hard-coded to 15 minutes)
  | LISTEN      /--listen          : Ex: localhost:80 or :443
  | PORT_FORWARD/--port-forward    : <from_port>:<to_port>,<...>:<:..>
  | SECRET      /--secret          : shared secret with telebit-relay (used for JWT Auth)
  |             /--spf-domain      : domain with SPF-like list of IP addresses are allowed to connect to clients
  |             / --token          : auth token for the server (instead of generating --secret)
  |                                  Use --token=false to ignore any $TOKEN in env
  |             / --env ./.env     : Use given config file instead of flags or Env.Vars.
  | ACME_HTTP_01_RELAY_URL/--acme-http-01-relay-url: base url of ACME HTTP-01 relay, if != DNS-01 relay
  | 
  | 
  | (check original web for a how-to build telebit)
  ```

[[reverse_proxy.telebit}]]
