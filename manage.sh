#!/bin/bash

set -e

COMPOSE_FILE="docker-compose.yml"

AVAILABLE_PROFILES=(
postgres
mongo
minio
redis
kafka
cdc
keycloak
elk
temporal
n8n
)

function show_help() {
echo "Usage:"
echo "  ./manage.sh up [profiles...]"
echo "  ./manage.sh down [profiles...]"
echo "  ./manage.sh up all"
echo "  ./manage.sh down all"
echo "  ./manage.sh menu"
echo ""
echo "Available profiles:"
echo "  ${AVAILABLE_PROFILES[*]}"
}

function build_profiles() {
local input_profiles=("$@")

if [[ "${input_profiles[0]}" == "all" ]]; then
PROFILES=("${AVAILABLE_PROFILES[@]}")
else
PROFILES=("${input_profiles[@]}")
fi

PROFILE_ARGS=""
for p in "${PROFILES[@]}"; do
PROFILE_ARGS+=" --profile $p"
done
}

function run_up() {
build_profiles "$@"
echo "Starting profiles: ${PROFILES[*]}"
docker compose $PROFILE_ARGS up -d
}

function run_down() {
build_profiles "$@"
echo "Stopping profiles: ${PROFILES[*]}"
docker compose $PROFILE_ARGS down
}

function interactive_menu() {
echo "Select profiles (space-separated, or type 'all'):"
echo "${AVAILABLE_PROFILES[*]}"
read -r selection

echo "Action? (up/down)"
read -r action

if [[ "$action" != "up" && "$action" != "down" ]]; then
echo "Invalid action"
exit 1
fi

if [[ "$selection" == "all" ]]; then
PROFILES=("all")
else
PROFILES=($selection)
fi

if [[ "$action" == "up" ]]; then
run_up "${PROFILES[@]}"
else
run_down "${PROFILES[@]}"
fi
}

# =========================

# Main

# =========================

if [[ $# -lt 1 ]]; then
show_help
exit 1
fi

COMMAND=$1
shift

case "$COMMAND" in
up)
run_up "$@"
;;
down)
run_down "$@"
;;
menu)
interactive_menu
;;
*)
show_help
;;
esac
