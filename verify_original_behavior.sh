#!/bin/bash
SERVICES_CONFIG="test_services.yml"

cat > test_services.yml <<EOF
services:
  cursor:
    enabled: true
    nested:
      enabled: false
EOF

load_services_config_original() {
    RUN_CURSOR=true
    if [[ ! -f "$SERVICES_CONFIG" ]]; then return 0; fi

    local cursor_section=$(sed -n '/^[[:space:]]*cursor:/,/^[[:space:]]*[a-z]*:/p' "$SERVICES_CONFIG" | head -20)
    # echo "DEBUG SECTION: $cursor_section"
    if echo "$cursor_section" | grep -qE "enabled:[[:space:]]*false"; then
        RUN_CURSOR=false
    elif echo "$cursor_section" | grep -qE "enabled:[[:space:]]*true"; then
        RUN_CURSOR=true
    fi
    echo "RUN_CURSOR=$RUN_CURSOR"
}

load_services_config_original
rm test_services.yml
