#!/bin/sh

die()
{
    [ $# -gt 0 ] && printf -- "%s\n" "$*"
    return 1
}

eos_walletd()
{
    eoscheck

    [ -f ${EOSIO_ROOT}/bin/eos-walletd ] \
        && wallet=${EOSIO_ROOT}/bin/eos-walletd
    [ -f ${EOSIO_ROOT}/bin/eosio-walletd ] \
        && wallet=${EOSIO_ROOT}/bin/eosio-walletd
    [ -f ${EOSIO_ROOT}/bin/eosiowd ] \
        && wallet=${EOSIO_ROOT}/bin/eosiowd
    [ -f ${EOSIO_ROOT}/bin/keosd ] \
        && wallet=${EOSIO_ROOT}/bin/keosd

    ${wallet} \
        --http-server-address=${EOSIO_WALLET_HOST}:${EOSIO_WALLET_PORT} \
        --wallet-dir=${EOSIO_WALLET_DIR} \
        --data-dir=${EOSIO_DATA_DIR} \
        $@
}

eosc()
{
    eoscheck

    [ -f ${EOSIO_ROOT}/bin/eosc ] \
        && eosc=${EOSIO_ROOT}/bin/eosc
    [ -f ${EOSIO_ROOT}/bin/eosioc ] \
        && eosc=${EOSIO_ROOT}/bin/eosioc
    [ -f ${EOSIO_ROOT}/bin/cleos ] \
        && eosc=${EOSIO_ROOT}/bin/cleos

    ${eosc} \
        --host ${EOSIO_HTTP_HOST} \
        --port ${EOSIO_HTTP_PORT} \
        --wallet-host ${EOSIO_WALLET_HOST} \
        --wallet-port ${EOSIO_WALLET_PORT} \
        $@
}

eoscheck()
{
    if [ "${EOSIO_ROOT}" = "" ] \
    || [ "${EOSIO_DATA_DIR}" = "" ] \
    || [ "${EOSIO_CONFIG_DIR}" = "" ] \
    || [ "${EOSIO_WALLET_DIR}" = "" ] \
    || [ "${EOSIO_HTTP_HOST}" = "" ] \
    || [ "${EOSIO_HTTP_PORT}" = "" ] \
    || [ "${EOSIO_WALLET_HOST}" = "" ] \
    || [ "${EOSIO_WALLET_PORT}" = "" ] ; then
        die "Environment variables are null, run eosconf."
    fi
}

eosconf()
{
    [ $# -eq 8 ] || die "Usage: eosconf root data_dir config_dir wallet_dir http_host http_port wallet_host wallet_port"

    export EOSIO_ROOT=${1}
    export EOSIO_DATA_DIR=${2}
    export EOSIO_CONFIG_DIR=${3}
    export EOSIO_WALLET_DIR=${4}
    export EOSIO_HTTP_HOST=${5}
    export EOSIO_HTTP_PORT=${6}
    export EOSIO_WALLET_HOST=${7}
    export EOSIO_WALLET_PORT=${8}
}

eoscpp()
{
    eoscheck

    [ -f ${EOSIO_ROOT}/bin/eoscpp ] \
        && eoscpp=${EOSIO_ROOT}/bin/eoscpp
    [ -f ${EOSIO_ROOT}/bin/eosiocpp ] \
        && eoscpp=${EOSIO_ROOT}/bin/eosiocpp

    ${eoscpp} $@
}

eosd()
{
    SKIP=0
    while getopts "s" OPTION; do
        case ${OPTION} in
            s)
                SKIP=1
        esac
    done
    if [ "${SKIP}" -eq 0 ]; then
        prompt_input_yN "clean" && rm -rf ${EOSIO_DATA_DIR}/{block*,shared_mem}
        prompt_input_yN "replay" && REPLAY=--replay
    fi

    [ -f ${EOSIO_ROOT}/bin/eosd ] \
        && eosd=${EOSIO_ROOT}/bin/eosd
    [ -f ${EOSIO_ROOT}/bin/eosiod ] \
        && eosd=${EOSIO_ROOT}/bin/eosiod
    [ -f ${EOSIO_ROOT}/bin/nodeos ] \
        && eosd=${EOSIO_ROOT}/bin/nodeos

    ${eosd} \
        --data-dir="${EOSIO_DATA_DIR}" \
        --config="${EOSIO_CONFIG_DIR}/config.ini" \
        --genesis-json="${EOSIO_CONFIG_DIR}/genesis.json" \
        ${REPLAY} \
        2>&1 | tee ${EOSIO_DATA_DIR}/log.$(date +'%Y_%m_%d_%H_%M_%S').txt
}

prompt_input_yN()
{
    printf "${1}? [y|N] "
    while true; do
        read -k 1 yn
        case ${yn} in
            [Yy]* ) printf "\n" && return 0; break;;
            * ) printf "\n" && return 1;;
        esac
    done
}