#!/bin/sh
# find-routes.sh: a first-pass inventory of HTTP routes and API contract files.
#
# Usage: find-routes.sh [project-root]
#
# This is a text search. Treat its output as leads, not as the inventory.
#   - It misses routes that are built dynamically or generated from a contract.
#   - It reports some lines that are not routes, such as outbound HTTP calls.
#   - Each section is cut at MAX lines. A notice is printed when that happens.
#   - It skips the directories listed in SKIPPED below, and says so.
#   - It prints a path as written in the file, without any mount or group
#     prefix, so "/items" may really be served at "/api/v1/items".
#   - "0 matches" means this pattern found nothing. It does not mean the
#     project has no routes of that kind.
# Always confirm the result by reading the router or controller files.
# It reads files only. It creates no files and sends nothing.
# It needs a grep with -r, --include and --exclude-dir (GNU or BSD grep).

ROOT="${1:-.}"
MAX=400
FAILED=0

# bytes, not characters, so one badly encoded line cannot stop a section
LC_ALL=C; export LC_ALL

if [ ! -d "$ROOT" ]; then
  echo "error: '$ROOT' is not a directory" >&2
  exit 2
fi

# a root that starts with a dash would be read as an option
case "$ROOT" in -*) ROOT="./$ROOT" ;; esac
# enter the root, so a symlinked root is followed and paths print relative to it
cd "$ROOT" || { echo "error: cannot enter '$ROOT'" >&2; exit 2; }
ROOT=.

SKIPPED='node_modules .git dist build out bin obj vendor venv .venv target __pycache__ .next .nuxt .svelte-kit .turbo coverage'
EXCLUDES=''
PRUNE=''
for d in $SKIPPED; do
  EXCLUDES="$EXCLUDES --exclude-dir=$d"
  PRUNE="$PRUNE -o -name $d"
done
PRUNE=${PRUNE# -o }

section() {
  printf '\n== %s ==\n' "$1"
}

search() {
  # $1 = label, $2 = extended regex, rest = --include patterns
  label="$1"; pattern="$2"; shift 2
  # shellcheck disable=SC2086
  all=$(grep -rnE $EXCLUDES "$@" -- "$pattern" "$ROOT" 2>/dev/null)
  status=$?
  section "$label"
  # grep exits 0 on a match, 1 on none, and 2 or more on an error
  if [ "$status" -gt 1 ]; then
    echo "[grep reported an error: some files were not searched, so this section is incomplete]"
    FAILED=1
  fi
  if [ -z "$all" ]; then
    echo "[0 matches]"
  else
    total=$(printf '%s\n' "$all" | wc -l | tr -d ' ')
    echo "[$total matches]"
    # long generated lines are cut so the output stays readable
    printf '%s\n' "$all" | cut -c1-240 | head -n "$MAX"
    if [ "$total" -gt "$MAX" ]; then
      echo "[truncated: showing $MAX of $total lines. Narrow the path and run again.]"
    fi
  fi
}

echo "Skipped directories, at any depth: $SKIPPED"
echo "If your own code lives in a directory with one of these names, search it directly."

section "Contract files, by name"
# shellcheck disable=SC2086
contracts=$(find "$ROOT" \
  \( $PRUNE \) -prune -o \
  -type f \( \
    -iname '*openapi*.y*ml' -o -iname '*openapi*.json' -o \
    -iname '*swagger*.y*ml' -o -iname '*swagger*.json' -o \
    -iname '*asyncapi*.y*ml' -o -iname '*asyncapi*.json' -o \
    -iname '*.arazzo.y*ml' -o -iname '*.graphql' -o -iname '*.graphqls' -o \
    -iname '*.proto' -o -iname 'llms.txt' -o -iname 'api-catalog*' \
  \) -print)
if [ -z "$contracts" ]; then
  echo "[0 matches. The next section finds contracts with other names.]"
else
  total=$(printf '%s\n' "$contracts" | wc -l | tr -d ' ')
  echo "[$total matches]"
  printf '%s\n' "$contracts" | head -n "$MAX"
  if [ "$total" -gt "$MAX" ]; then
    echo "[truncated: showing $MAX of $total lines. Narrow the path and run again.]"
  fi
fi

# a version string must follow the key, so package.json scripts and config keys do not match
search "Files that declare an OpenAPI or AsyncAPI document" \
  '(^|[{,[:space:]])["'"'"']?(openapi|swagger|asyncapi)["'"'"']?[[:space:]]*:[[:space:]]*["'"'"']?[0-9]+\.[0-9]' \
  --include='*.yaml' --include='*.yml' --include='*.json' --exclude='package*.json'

search "Express, Fastify, Koa, Hono (JavaScript and TypeScript)" \
  '[A-Za-z_$][A-Za-z0-9_$]*\.(get|post|put|patch|delete|options|head|all)[[:space:]]*\([[:space:]]*["'"'"'`]/' \
  --include='*.js' --include='*.ts' --include='*.mjs' --include='*.cjs' --include='*.tsx'

search "Route objects and chained routes (JavaScript and TypeScript)" \
  '\.route[[:space:]]*\(|\.on[[:space:]]*\([[:space:]]*["'"'"'](GET|POST|PUT|PATCH|DELETE)' \
  --include='*.js' --include='*.ts' --include='*.mjs' --include='*.cjs'

search "Router mounts and prefixes (JavaScript and TypeScript)" \
  '\.use[[:space:]]*\([[:space:]]*["'"'"'`]/' \
  --include='*.js' --include='*.ts' --include='*.mjs' --include='*.cjs'

search "File-based route handlers (Next.js, SvelteKit, Remix)" \
  'export[[:space:]]+(async[[:space:]]+)?(function|const)[[:space:]]+(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS|loader|action)\b' \
  --include='*.js' --include='*.ts' --include='*.mjs' --include='*.tsx' --include='*.jsx'

search "NestJS decorators" \
  '@(Get|Post|Put|Patch|Delete|Head|Options|All|Controller)[[:space:]]*\(' \
  --include='*.ts'

search "Flask, FastAPI, Django (Python)" \
  '@[A-Za-z_][A-Za-z0-9_]*\.(get|post|put|patch|delete|route|api_route|websocket)[[:space:]]*\(|(^|[^.A-Za-z0-9_])(path|re_path)[[:space:]]*\(|router\.register[[:space:]]*\([[:space:]]*r?["'"'"']|add_api_route[[:space:]]*\(|@(action|api_view)[[:space:]]*\(|APIRouter[[:space:]]*\(|include_router[[:space:]]*\(' \
  --include='*.py'

search "Spring (Java and Kotlin)" \
  '@(GetMapping|PostMapping|PutMapping|PatchMapping|DeleteMapping|RequestMapping)\b' \
  --include='*.java' --include='*.kt'

search "JAX-RS (Java and Kotlin)" \
  '@(GET|POST|PUT|PATCH|DELETE|Path)\b' \
  --include='*.java' --include='*.kt'

search "Ktor (Kotlin)" \
  '(^|[[:space:]])(get|post|put|patch|delete|route)[[:space:]]*\([[:space:]]*"/' \
  --include='*.kt'

search "Go (net/http, chi, gin, echo)" \
  '\.(HandleFunc|Handle|Get|Post|Put|Patch|Delete|GET|POST|PUT|PATCH|DELETE|Any|Method|Route|Mount|Group)[[:space:]]*\([[:space:]]*("[A-Z]+",[[:space:]]*)?"(/|[A-Z]+ /)' \
  --include='*.go'

search "Rails routes and Grape (Ruby)" \
  '^[[:space:]]*(get|post|put|patch|delete|resources|resource|namespace|mount)[[:space:]]' \
  --include='routes.rb' --include='*routes*.rb' --include='config.ru' --include='*api*.rb'

search "Laravel and Symfony routes (PHP)" \
  'Route::[A-Za-z]+[[:space:]]*\(|->(get|post|put|patch|delete)[[:space:]]*\([[:space:]]*["'"'"']/|#\[Route' \
  --include='*.php'

search "ASP.NET (C#)" \
  '\[(HttpGet|HttpPost|HttpPut|HttpPatch|HttpDelete|HttpHead|HttpOptions|AcceptVerbs|Route)\b|\.Map(Get|Post|Put|Patch|Delete|Group|Methods|Controllers|Hub)[[:space:]]*[<(]' \
  --include='*.cs'

search "Well-known and agent-facing endpoints, and lifecycle headers" \
  '\.well-known/|llms\.txt|text/markdown|Signature-Agent|Idempotency-Key|RateLimit-Policy|["'"'"'](Deprecation|Sunset)["'"'"']' \
  --include='*.js' --include='*.ts' --include='*.py' --include='*.go' --include='*.java' --include='*.kt' --include='*.rb' --include='*.php' --include='*.cs' --include='*.y*ml' --include='*.conf'

section "Not searched by this script"
# shellcheck disable=SC2086
others=$(find "$ROOT" \( $PRUNE \) -prune -o -type f \( \
    -name '*.rs' -o -name '*.ex' -o -name '*.exs' -o -name '*.scala' -o -name '*.groovy' -o \
    -name '*.fs' -o -name '*.vb' -o -name '*.tf' -o -name 'serverless.y*ml' \
  \) -print | sed 's/.*\.//' | sort | uniq -c)
if [ -z "$others" ]; then
  echo "[no source files of a kind this script does not cover]"
else
  echo "Files of these types exist and were not searched for routes. Read them yourself:"
  printf '%s\n' "$others"
fi

section "Done"
echo "Text search only. Confirm against the router and the contract before relying on this list."
if [ "$FAILED" -ne 0 ]; then
  echo "At least one search failed, so this output is incomplete." >&2
  exit 1
fi
