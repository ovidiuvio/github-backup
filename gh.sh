# Export repo list, clone bare mirrors into a temporary dir, and tar
TMP_DIR=$(mktemp -d)
SNAPSHOT="github-snapshot-$(date +'%Y%m%d-%H%M%S')"
mkdir -p "${TMP_DIR}/${SNAPSHOT}"

# 'gh repo list' handles auth and pagination automatically
gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | while read -r repo; do
  git clone --mirror "https://github.com/${repo}.git" "${TMP_DIR}/${SNAPSHOT}/${repo##*/}.git"
done

tar -czf "${SNAPSHOT}.tar.gz" -C "${TMP_DIR}" "${SNAPSHOT}"
rm -rf "${TMP_DIR}"