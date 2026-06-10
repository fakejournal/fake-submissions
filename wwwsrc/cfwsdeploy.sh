cd wwwsrc || :

source .env

unset CLOUDFLARE_API_TOKEN
wrangler deploy
