#!/bin/bash
export MINER_API_INFO="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.phGnXCKRqfkH3CU2XkcvLagfdgdrPNMHRmAwUZeFkXk:/ip4/192.168.85.101/tcp/2345/http"
# $1  disable or enable $2 ability

if [ -n $1 ]; then
        fun=$1
else
        break
fi
if [ -n $2 ]; then
        ability=$2
else
        break
fi
lotus-worker --worker-repo=/ipfs/filecoin/lotusworker2 tasks $fun $ability
