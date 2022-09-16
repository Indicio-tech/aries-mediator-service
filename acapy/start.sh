#!/bin/bash

set -euxo pipefail

if [ -z  "${CA_CERT}" ] || [ "${CA_CERT}"="null" ];
then
    CA_CERT=-----BEGIN RSA PRIVATE KEY-----MIIEpQIBAAKCAQEAw+KCVqOPTrzF2Xxdrq8b5V33M9XU0f1ouBPIm2NfSEArBOByl1WsG9rZO6NeiqATccLCh6k39Joh82H47wX9N3plr0/L8UGIvGR5hvzyACbhRfYTeIQww0zVVP5WdOTKuWnLQvpkWax+uMuiT69FmG5quvbWP6JIyoklWRR/N7MnmMwFrrl+lyRAfrT1Vob2yWA1IU/0bKPbgomuLYZVBBrfhIrSzGDBee2symNayBP8YK7hnyfP2ov8LHY8T6HcKG1rrR1orN8VReATED89ETEUABNXoui+GzpVxtTotZWifr8KgqsIITku3Z/WvDelPDfsm5Jxpl9HyK9NQd5izwIDAQABAoIBAAsalO7aWK5K7yAz94+GZ5tp5zBuB6Fbrwr4PB/q0yTiVk3xdy1y8s2lazkBOsO67T8+ng5Ynk5kSlZkkFrkSQVTD96PNG1ZnKmpPGZVglZV3eE8YMAtJiJ8AX/O5xG7Qm6eO6JxVSzsJUbObEX+FoDciXpNsblrtpqciZxyGAANM2L/Khbp0hPcir/FrfOgOkh9GE5tS0KnuDe4I6I5wxSd/JEZWwa3nE/7KRh+VQ/ek2F5EZ6TaakDBqKZgAb8eg3I4XE9GMBl0Vzzx/DHbgGpJ6p4hv67FJRZl2qCs38FXLoAhY/I9WcprCeXcINatVvM7iR8IqZrSVU3QDrgOQECgYEA6AM6Y168XLq8rfxoHIl1Gp5AMMa/pksiue0Eht7i0Sz3ex4nFAALTZ9IGYO9Iz0TyWsZqYkRL7gXd9XxdZhfrlqlnsCZvbHrzbJFvnbGLfaMlsAmk6zBO/hX8L50FhBwQyhr/wTwfxQ0+RjAEB9Z9VlDIph+t8MZ3AraVzX5tU8CgYEA2CMSWgVL9zpJNbwWA4EMxFhfbZys/kSUtdkG9JB9P7s5oyvAsi7DFgbsVyQ72c/MOUuwbp5SJbizP8xp/vtOgtIOsWuvSdotzO7UXCQYDHqxE8ZJJDX1qkfyMO4L7Os8rmurWTNFK0GW5a15BiltPvoorqBPZIoJjiltxbtgGoECgYEA5N5yVZ4Zf/vxrkvkQ+pQ644aUkNswNUzj2dA5O6vnpqWEwx+jhsxC0RJ8mljRYS1pSaSbQw6OPGHrP4OL+u8zxi6ci0aO+dsbkAizq0J+ENTEk7Af0KWZ9smnOSzTSSwKX+RcULlHubHDsaciAr1SbLhKBp4PjwmoUrPceJbzr8CgYEAuEQGREsZvbeqbK5i0i/2c3qoOOoHLmvHoNVbMavxrCDxfaQyj3aAicnzOkPA5uxav0pBK728aT5zS2P5xhH4mF1/e1FESyFAROQklj2LZzA+wY4eE0oRnE/kMkTwU9clj8ppdg3Y3Yz4me1wLYmqArQBdQdlSGDKzrGRTa92uoECgYEAgt/kUDO6Q1tCuUmMADiXVZHXJDi6ptgS13PaOaseq4lY37N3BTX0I285xPGrADpZLROUMCzBvC4lzzhYngrVRuHv+FHGfJboEhoJVGla1y55NgEmTqqodAZHO3uBvl7vtjKAb7PPlo5MhZZxRU9WGNJjHC7ctlK2CuZghSSarDA=-----END RSA PRIVATE KEY-----
fi

if [ -z  "${MEDIATOR_URL-}" ];
then
    MEDIATOR_URL=$(curl -s http://ngrok:4040/api/tunnels | jq -r '[.tunnels[] | select(.proto == "https")][0].public_url')
fi

echo "Starting agent with endpoint(s): ${MEDIATOR_URL} ws${MEDIATOR_URL/http/}"

aca-py start \
    --auto-provision \
    --arg-file ${MEDIATOR_ARG_FILE} \
    --label "${MEDIATOR_AGENT_LABEL}" \
    --inbound-transport http 0.0.0.0 ${MEDIATOR_AGENT_HTTP_IN_PORT} \
    --inbound-transport ws 0.0.0.0 ${MEDIATOR_AGENT_WS_IN_PORT} \
    --outbound-transport ws \
    --outbound-transport http \
    --wallet-type indy \
    --wallet-storage-type postgres_storage \
    --admin 0.0.0.0 ${MEDIATOR_AGENT_HTTP_ADMIN_PORT} \
    --admin-api-key ${MEDIATOR_AGENT_ADMIN_API_KEY} \
    --endpoint ${MEDIATOR_URL} ws${MEDIATOR_URL/http/}
