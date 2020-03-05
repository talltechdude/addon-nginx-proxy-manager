#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Nginx Proxy Manager
# This file geneates the Vouch configuration
# ==============================================================================

export LOG_LEVEL=$(bashio::config 'log_level')
export DOMAIN=$(bashio::config 'domain')
export JWT_MAX_AGE=$(bashio::config 'jwt_max_age')
export VOUCH_URL=$(bashio::config 'vouch_url')
export HOMEASSISTANT_URL=$(bashio::config 'homeassistant_url')

envsubst '$LOG_LEVEL $DOMAIN $JWT_MAX_AGE $VOUCH_URL $HOMEASSISTANT_URL' < "/opt/vouch/config.template.yml" > "/data/vouch-config.yml" 

if ! bashio::fs.directory_exists "/data/nginx/custom"; then
    mkdir -p /data/nginx/custom
fi
ln -s /opt/vouch/http.conf /data/nginx/custom/http.conf

envsubst '$VOUCH_URL' < "/opt/vouch/server_proxy.conf" > "/data/nginx/custom/server_proxy.conf" 
