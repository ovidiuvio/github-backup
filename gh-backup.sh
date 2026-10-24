# Export repo list, clone bare mirrors into a temporary dir, and tar
TMP_DIR=$(mktemp -d)
SNAPSHOT="github-snapshot-$(date +'%Y%m%d-%H%M%S')"
mkdir -p "${TMP_DIR}/${SNAPSHOT}"

# Autodetect protocol: try SSH first, fall back to HTTPS
if ssh -n -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com 2>&1 | grep -qi "successfully authenticated"; then
  GIT_URL_PREFIX="git@github.com:"
else
  GIT_URL_PREFIX="https://github.com/"
fi

# 'gh repo list' handles auth and pagination automatically
gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | while read -r repo; do
  git clone --mirror "${GIT_URL_PREFIX}${repo}.git" "${TMP_DIR}/${SNAPSHOT}/${repo##*/}.git"
done

tar -czf "${SNAPSHOT}.tar.gz" -C "${TMP_DIR}" "${SNAPSHOT}"
rm -rf "${TMP_DIR}"