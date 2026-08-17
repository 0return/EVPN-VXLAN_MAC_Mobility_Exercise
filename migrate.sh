#!/usr/bin/env bash

set -euo pipefail

LAB="Lab_L2_EVPN"
CUST="Customer100-1"
CUST_IF="eth1.100"
CUST_IP="192.168.100.1"
PEER_IP="192.168.100.3"

SRC_NODE="${1:-leaf1}"
SRC_IF="${2:-e1-3}"
DST_NODE="${3:-leaf2}"
DST_IF="${4:-e1-5}"
TMP="clabmig0"

pid() { docker inspect -f '{{.State.Pid}}' "clab-${LAB}-$1"; }

SRC_PID="$(pid "$SRC_NODE")"
DST_PID="$(pid "$DST_NODE")"

echo "[*] ${SRC_NODE}:${SRC_IF} (pid ${SRC_PID})  ->  ${DST_NODE}:${DST_IF} (pid ${DST_PID})"


nsenter -t "$SRC_PID" -n ip -o link show "$SRC_IF" >/dev/null 2>&1 \
  || { echo "ERROR: ${SRC_IF} do not exist on ${SRC_NODE}. Cancelling."; exit 1; }

if nsenter -t "$DST_PID" -n ip -o link show "$DST_IF" >/dev/null 2>&1; then
  echo "ERROR: ${DST_IF} already exist onf ${DST_NODE}."; exit 1
fi


nsenter -t "$SRC_PID" -n ip link set "$SRC_IF" down
nsenter -t "$SRC_PID" -n ip link set "$SRC_IF" name "$TMP"
nsenter -t "$SRC_PID" -n ip link set "$TMP"     netns "$DST_PID"
nsenter -t "$DST_PID" -n ip link set "$TMP"     name "$DST_IF"
nsenter -t "$DST_PID" -n ip link set "$DST_IF"  up

echo "[*] Link has moved. ${DST_NODE} must link the netdev ${DST_IF} to its corresponding Ethernet interface."


docker exec "clab-${LAB}-${CUST}" sh -c \
  "arping -U -c 3 -I ${CUST_IF} ${CUST_IP} 2>/dev/null || ping -c 3 -w 3 ${PEER_IP}" || true

echo "[*] Migracion completa. Verifica con:  ./verify-after.sh"
