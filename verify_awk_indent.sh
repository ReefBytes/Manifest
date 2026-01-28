#!/bin/bash

cat > test_services.yml <<EOF
services:
  claude:
    command: foo
    enabled: true

  # Comment
  logging:
    enabled: false

  gemini:
    enabled: true

  cursor:
    enabled: true
    nested:
      enabled: false

minimum_agents: 2
EOF

parse_config() {
    awk '
    function get_indent(s) { match(s, /^[[:space:]]*/); return RLENGTH }

    BEGIN { ctx=""; indent=0 }

    /^[[:space:]]*claude:/ { ctx="claude"; indent=get_indent($0); next }
    /^[[:space:]]*gemini:/ { ctx="gemini"; indent=get_indent($0); next }
    /^[[:space:]]*cursor:/ { ctx="cursor"; indent=get_indent($0); next }

    # Check for section end
    ctx != "" {
        curr_indent = get_indent($0)
        # If line is not empty and indent is <= section indent
        if ($0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*#/ && curr_indent <= indent) {
            # print "DEBUG: End of section " ctx " at line: " $0
            ctx = ""
        }
    }

    ctx=="claude" && /enabled:[[:space:]]*false/ { print "RUN_CLAUDE=false"; }
    ctx=="claude" && /enabled:[[:space:]]*true/ { print "RUN_CLAUDE=true"; }

    ctx=="gemini" && /enabled:[[:space:]]*false/ { print "RUN_GEMINI=false"; }
    ctx=="gemini" && /enabled:[[:space:]]*true/ { print "RUN_GEMINI=true"; }

    ctx=="cursor" && /enabled:[[:space:]]*false/ { print "RUN_CURSOR=false"; }
    ctx=="cursor" && /enabled:[[:space:]]*true/ { print "RUN_CURSOR=true"; }

    /^minimum_agents:/ { match($0, /[0-9]+/); print "min_agents=" substr($0, RSTART, RLENGTH) }
    ' test_services.yml
}

echo "--- Parsing Output ---"
parse_config
echo "--- End Output ---"
rm test_services.yml
