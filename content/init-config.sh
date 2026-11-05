#!/bin/sh
# Create the PiGallery2 config file on first start.
#
# Why this exists: with an empty config, PiGallery2 creates a default
# `admin`/`admin` account (SQLConnection.ts: only skipped when an Admin or
# Developer role already exists). We therefore pre-seed `enforcedUsers` with an
# Admin whose password comes from the deploy parameters -- verified in
# src/backend/model/database/SQLConnection.ts that enforced users are inserted
# BEFORE the default-admin check, so the weak account never gets created.
#
# `password` is given in plain text on purpose: PrivateConfigClass.ts encrypts
# it on load and clears the field, so we must not pre-hash it ourselves.
set -e

CFG_DIR=/app/data/config
CFG="$CFG_DIR/config.json"

mkdir -p "$CFG_DIR"

if [ -f "$CFG" ]; then
  echo "config.json already exists, leaving it untouched"
  exit 0
fi

cat > "$CFG" <<EOF
{
  "Users": {
    "authenticationRequired": true,
    "enforcedUsers": [
      {
        "name": "${PG2_ADMIN_USER}",
        "role": 4,
        "password": "${PG2_ADMIN_PASSWORD}"
      }
    ]
  }
}
EOF

echo "wrote $CFG with enforced admin '${PG2_ADMIN_USER}'"
