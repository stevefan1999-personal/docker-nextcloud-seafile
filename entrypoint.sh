#!/bin/bash

IFS=
filename="seadrive.conf"

mkdir -p /data/seadrive-fuse

if [[ ! -f "$filename" ]]; then
  echo "[INFO] $filename does not exist, generating..."
  if [ -z "$SEAFILE_HOST" ]; then
    echo "[ERROR] Hostname is required"
    exit 1
  fi

  if [ -z "$SEAFILE_TOKEN" ] && ([ -z "$SEAFILE_USERNAME" ] || [ -z "$SEAFILE_PASSWORD" ]); then
    echo "[ERROR] Token is not supplied and no user name or password available for automatic generation"
    exit 1
  elif [ -z "$SEAFILE_TOKEN" ]; then
    echo "[INFO] Found user & pass"
    token=$(
      curl -s \
        -d "username=$SEAFILE_USERNAME" \
        -d "password=$SEAFILE_PASSWORD" \
        $SEAFILE_HOST/api2/auth-token/ |
      jq -r '.token'
    )

    if [ -z "$token" ] || [ "$token" == "null" ]; then
        echo "[ERROR] Failed to retrieve token: authentication failed"
        exit 1
    fi
    SEAFILE_TOKEN=$token
  fi


  config_template="\
[account]
server = $SEAFILE_HOST
username = $SEAFILE_USERNAME
token = $SEAFILE_TOKEN
is_pro = $SEAFILE_IS_PRO

[general]
client_name = nextcloud

[cache]
size_limit = 10GB
clean_cache_interval = 10
"
  echo "[INFO] Generating this config to $filename:\""
  echo "$config_template\""
  echo $config_template >> $filename
  if [[ -f "$filename" ]]; then
    echo "[INFO] Done"
  else
    echo "[ERROR] Failed to generate $filename: permission denied"
    exit 1
  fi

else
  echo "[INFO] Previous configuration of $filename found..."
fi

echo "[INFO] Starting seadrive..."
seadrive -f -c /data/$filename -o nonempty,allow_other -d /data/seadrive-data /data/seadrive-fuse -l /dev/stdout &

echo "[INFO] Patching nextcloud config to ignore permission check..."
cd /var/www/html
echo "[INFO] Starting nextcloud..."
/entrypoint.sh apache2-foreground
sudo -u www-data php occ config:system:set check_data_directory_permissions --value="false" --type=boolean
