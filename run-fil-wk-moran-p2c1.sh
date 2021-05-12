export MINER_API_INFO=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiLCJzaWduIiwiYWRtaW4iXX0.sbKnUI6V1If08_-z_9_knoPcYZw-Dkq0nosaALph6bo:/ip4/192.168.85.102/tcp/2345/http
export FIL_PROOFS_PARAMETER_CACHE=/ipfs/filecoin/filecoin-proof-parameters-v28 
export FIL_PROOFS_PARENT_CACHE=/ipfs/filecoin/filecoin-parents-cache 
export TMPDIR=/ipfs/filecoin/tmpdir2
export RUST_BACKTRACE=info
export RUST_LOG=info
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
export BELLMAN_CPU_UTILIZATION=0
export wkip=`LC_ALL=C ifconfig | grep 'inet'| grep -v '127.0.0.1'|grep -v inet6 |awk '{print $2}'`
nohup taskset -c 0-23 lotus-worker --worker-repo /ipfs/filecoin/lotusworker2 run --listen $wkip:3457 --ability=AP:1,PC1:0,PC2:1,C1:1,C2:0  > /ipfs/filecoin/lotusworker2.log 2>&1 &
