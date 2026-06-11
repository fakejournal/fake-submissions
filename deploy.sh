#!/bin/bash



### New code: Upload to Cloudflare R2



### Step 1: Ask maintainer to grant you access to R2 bucket on Cloudflare.
### Step 2: Generate your API token and save these in `.env` file.
# export R2_ACCOUNT_ID=xxx
# export R2_ACCESS_KEY_ID=xxx
# export R2_SECRET_ACCESS_KEY=xxx

source .env


case $1 in
	all )
		find _dist -type f | node _utils/r2syncup.mjs
		;;
	* )
		### Only files new enough (modified within 7 days) are tried
		find _dist -type f -mmin -$((24 * 60 * 7)) | node _utils/r2syncup.mjs
		;;
esac


