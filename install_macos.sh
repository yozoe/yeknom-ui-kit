#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
  pwd
)"
readonly EXAMPLE_DIR="${SCRIPT_DIR}/example"
readonly PRODUCT_NAME="yeknom_ui_kit_example"
readonly DISPLAY_NAME="Yeknom UI Kit Catalog"
readonly BUNDLE_ID="com.yeknom.yeknomUiKitExample"
readonly BUILD_APP="${EXAMPLE_DIR}/build/macos/Build/Products/Release/${PRODUCT_NAME}.app"
readonly INSTALL_DIR="/Applications"
readonly INSTALL_APP="${INSTALL_DIR}/${DISPLAY_NAME}.app"
readonly INSTALLED_EXECUTABLE="${INSTALL_APP}/Contents/MacOS/${PRODUCT_NAME}"
readonly LOCK_DIR="/private/tmp/.${PRODUCT_NAME}.install.lock"
readonly LOCK_OWNER_FILE="${LOCK_DIR}/owner"
readonly CURRENT_UID="$(/usr/bin/id -u)"
readonly CURRENT_GID="$(/usr/bin/id -g)"

lock_acquired=false
installer_requires_sudo=false
active_child_pid=
transaction_dir=
staging_app=
backup_app=
staging_identity=
had_existing=false
rollback_needed=false
old_app_was_running=false

log() {
  printf '[yeknom-ui-kit] %s\n' "$*"
}

warn() {
  printf '[yeknom-ui-kit] warning: %s\n' "$*" >&2
}

fail() {
  printf '[yeknom-ui-kit] error: %s\n' "$*" >&2
  exit 1
}

path_exists() {
  [[ -e "$1" || -L "$1" ]]
}

path_identity() {
  /usr/bin/stat -f '%d:%i' "$1" 2>/dev/null
}

path_matches_staging_identity() {
  local path=$1
  local actual_identity

  [[ -n "${staging_identity}" ]] || return 1
  [[ -d "${path}" && ! -L "${path}" ]] || return 1
  actual_identity="$(path_identity "${path}" || true)"
  [[ "${actual_identity}" == "${staging_identity}" ]]
}

run_installer_command() {
  if [[ "${installer_requires_sudo}" == true ]]; then
    /usr/bin/sudo -n "$@"
  else
    "$@"
  fi
}

path_has_foreign_owner() {
  local path=$1
  local foreign_path

  if ! foreign_path="$(
    /usr/bin/find "${path}" ! -user "${CURRENT_UID}" -print -quit 2>/dev/null
  )"; then
    return 0
  fi

  [[ -n "${foreign_path}" ]]
}

configure_installer_privileges() {
  if [[ ! -w "${INSTALL_DIR}" ]] ||
    { path_exists "${INSTALL_APP}" && path_has_foreign_owner "${INSTALL_APP}"; }; then
    installer_requires_sudo=true
  fi

  if [[ "${installer_requires_sudo}" == true ]]; then
    [[ -x /usr/bin/sudo ]] ||
      fail "Writing to ${INSTALL_DIR} requires administrator access, but sudo is unavailable."
    /usr/bin/sudo -v ||
      fail "Administrator access is required to install into ${INSTALL_DIR}."
  fi
}

installer_process_is_active() {
  local pid=$1
  local process_command

  [[ "${pid}" =~ ^[0-9]+$ ]] || return 1

  process_command="$(/bin/ps -p "${pid}" -o command= 2>/dev/null || true)"
  [[ -n "${process_command}" && "${process_command}" == *"install_macos.sh"* ]]
}

lock_owner_pid() {
  /usr/bin/sed -n '1p' "${LOCK_OWNER_FILE}" 2>/dev/null || true
}

ensure_install_lock_is_available() {
  local owner_pid

  path_exists "${LOCK_DIR}" || return 0
  [[ -d "${LOCK_DIR}" && ! -L "${LOCK_DIR}" ]] ||
    fail "Refusing to use an unsafe install lock: ${LOCK_DIR}"

  owner_pid="$(lock_owner_pid)"
  if installer_process_is_active "${owner_pid}"; then
    fail "Another installer is active with PID ${owner_pid}."
  fi

  fail "An existing install lock could not be verified as active. Confirm that no installer is running, then remove it manually: ${LOCK_DIR}"
}

release_install_lock() {
  local owner_pid

  [[ "${lock_acquired}" == true ]] || return 0

  if [[ -L "${LOCK_DIR}" || ! -d "${LOCK_DIR}" ]]; then
    warn "Install lock has an unsafe type and was not removed: ${LOCK_DIR}"
    return 1
  fi

  owner_pid="$(lock_owner_pid)"
  if [[ -z "${owner_pid}" ]]; then
    if /bin/rmdir -- "${LOCK_DIR}"; then
      lock_acquired=false
      return 0
    fi
    warn "Install lock has no owner metadata and could not be removed: ${LOCK_DIR}"
    return 1
  fi
  if [[ "${owner_pid}" != "$$" ]]; then
    warn "Install lock ownership changed; refusing to remove ${LOCK_DIR}"
    return 1
  fi

  if ! /bin/rm -f -- "${LOCK_OWNER_FILE}"; then
    warn "Could not remove install lock metadata: ${LOCK_OWNER_FILE}"
    return 1
  fi
  if /bin/rmdir -- "${LOCK_DIR}"; then
    lock_acquired=false
    return 0
  fi

  warn "Could not remove install lock: ${LOCK_DIR}"
  return 1
}

acquire_install_lock() {
  ensure_install_lock_is_available

  if ! /bin/mkdir -- "${LOCK_DIR}"; then
    if path_exists "${LOCK_DIR}"; then
      fail "Another installer acquired the lock: ${LOCK_DIR}"
    fi
    fail "Could not create the install lock in /private/tmp."
  fi
  lock_acquired=true

  /bin/chmod 0700 "${LOCK_DIR}" ||
    fail "Could not secure the install lock: ${LOCK_DIR}"
  printf '%s\n%s\n' "$$" "${SCRIPT_DIR}/install_macos.sh" >"${LOCK_OWNER_FILE}" ||
    fail "Could not write install lock metadata."
}

create_transaction_directory() {
  transaction_dir="$(
    run_installer_command /usr/bin/mktemp \
      -d "${INSTALL_DIR}/.${PRODUCT_NAME}.transaction.XXXXXX"
  )"
  [[ "${transaction_dir}" == "${INSTALL_DIR}/.${PRODUCT_NAME}.transaction."* ]] ||
    fail "mktemp returned an unexpected transaction directory: ${transaction_dir}"
  [[ -d "${transaction_dir}" && ! -L "${transaction_dir}" ]] ||
    fail "Could not create a secure transaction directory."

  if [[ "${installer_requires_sudo}" == true ]]; then
    run_installer_command /usr/sbin/chown \
      "${CURRENT_UID}:${CURRENT_GID}" "${transaction_dir}" ||
      fail "Could not grant access to the transaction directory."
  fi
  /bin/chmod 0700 "${transaction_dir}" ||
    fail "Could not secure the transaction directory."
}

bundle_id_for_app() {
  local app_path=$1
  /usr/libexec/PlistBuddy \
    -c 'Print :CFBundleIdentifier' \
    "${app_path}/Contents/Info.plist" \
    2>/dev/null
}

validate_app_bundle() {
  local app_path=$1
  local actual_bundle_id
  local executable_path="${app_path}/Contents/MacOS/${PRODUCT_NAME}"

  [[ -d "${app_path}" && ! -L "${app_path}" ]] ||
    fail "App bundle is not a regular directory: ${app_path}"
  [[ -f "${app_path}/Contents/Info.plist" ]] ||
    fail "App bundle is missing Info.plist: ${app_path}"
  [[ -x "${executable_path}" ]] ||
    fail "App bundle is missing its executable: ${executable_path}"

  actual_bundle_id="$(bundle_id_for_app "${app_path}" || true)"
  [[ "${actual_bundle_id}" == "${BUNDLE_ID}" ]] ||
    fail "Unexpected bundle identifier in ${app_path}: ${actual_bundle_id:-missing}"

  /usr/bin/codesign --verify --deep --strict "${app_path}"
}

executable_path_for_pid() {
  local pid=$1
  /usr/sbin/lsof -a -p "${pid}" -d txt -Fn 2>/dev/null |
    /usr/bin/awk '/^n/ { print substr($0, 2); exit }'
}

pid_matches_executable() {
  local pid=$1
  local expected_path=$2
  local executable_path

  executable_path="$(executable_path_for_pid "${pid}" || true)"
  [[ "${executable_path}" == "${expected_path}" ]]
}

pid_matches_bundle() {
  local pid=$1
  local executable_path
  local executable_suffix="/Contents/MacOS/${PRODUCT_NAME}"
  local app_path
  local actual_bundle_id

  executable_path="$(executable_path_for_pid "${pid}" || true)"
  [[ "${executable_path}" == *"${executable_suffix}" ]] || return 1

  app_path="${executable_path%"${executable_suffix}"}"
  actual_bundle_id="$(bundle_id_for_app "${app_path}" || true)"
  [[ "${actual_bundle_id}" == "${BUNDLE_ID}" ]]
}

candidate_pids() {
  /usr/bin/pgrep -u "${CURRENT_UID}" -f "${PRODUCT_NAME}" 2>/dev/null || true
}

pids_for_bundle() {
  local candidates
  local pid

  candidates="$(candidate_pids)"
  while IFS= read -r pid; do
    [[ "${pid}" =~ ^[0-9]+$ ]] || continue
    if pid_matches_bundle "${pid}"; then
      printf '%s\n' "${pid}"
    fi
  done <<<"${candidates}"
}

pids_for_executable() {
  local expected_path=$1
  local candidates
  local pid

  candidates="$(candidate_pids)"
  while IFS= read -r pid; do
    [[ "${pid}" =~ ^[0-9]+$ ]] || continue
    if pid_matches_executable "${pid}" "${expected_path}"; then
      printf '%s\n' "${pid}"
    fi
  done <<<"${candidates}"
}

wait_for_bundle_exit() {
  for _ in {1..40}; do
    if [[ -z "$(pids_for_bundle)" ]]; then
      return 0
    fi
    sleep 0.25
  done

  return 1
}

wait_for_installed_process() {
  local pids
  local pid

  for _ in {1..40}; do
    pids="$(pids_for_executable "${INSTALLED_EXECUTABLE}")"
    while IFS= read -r pid; do
      [[ "${pid}" =~ ^[0-9]+$ ]] || continue
      printf '%s\n' "${pid}"
      return 0
    done <<<"${pids}"
    sleep 0.25
  done

  return 1
}

wait_for_executable_exit() {
  local expected_path=$1

  for _ in {1..20}; do
    if [[ -z "$(pids_for_executable "${expected_path}")" ]]; then
      return 0
    fi
    sleep 0.25
  done

  return 1
}

terminate_bundle_processes() {
  local pids
  local pid

  pids="$(pids_for_bundle)"
  while IFS= read -r pid; do
    [[ "${pid}" =~ ^[0-9]+$ ]] || continue
    pid_matches_bundle "${pid}" || continue
    /bin/kill -TERM "${pid}" 2>/dev/null || true
  done <<<"${pids}"
}

installed_process_is_stable() {
  local pid=$1
  local executable_path

  for _ in {1..8}; do
    /bin/kill -0 "${pid}" 2>/dev/null || return 1
    executable_path="$(executable_path_for_pid "${pid}" || true)"
    [[ "${executable_path}" == "${INSTALLED_EXECUTABLE}" ]] || return 1
    sleep 0.25
  done
}

terminate_process_tree() {
  local parent_pid=$1
  local signal_name=$2
  local expected_parent_pid=$3
  local children
  local child_pid
  local child_parent
  local child_uid
  local parent_parent
  local parent_uid

  parent_parent="$(
    /bin/ps -p "${parent_pid}" -o ppid= 2>/dev/null |
      /usr/bin/tr -d '[:space:]'
  )"
  parent_uid="$(
    /bin/ps -p "${parent_pid}" -o uid= 2>/dev/null |
      /usr/bin/tr -d '[:space:]'
  )"
  [[ "${parent_parent}" == "${expected_parent_pid}" ]] || return
  [[ "${parent_uid}" == "${CURRENT_UID}" ]] || return

  children="$(
    /usr/bin/pgrep -u "${CURRENT_UID}" -P "${parent_pid}" 2>/dev/null || true
  )"
  while IFS= read -r child_pid; do
    [[ "${child_pid}" =~ ^[0-9]+$ ]] || continue
    child_parent="$(
      /bin/ps -p "${child_pid}" -o ppid= 2>/dev/null |
        /usr/bin/tr -d '[:space:]'
    )"
    child_uid="$(
      /bin/ps -p "${child_pid}" -o uid= 2>/dev/null |
        /usr/bin/tr -d '[:space:]'
    )"
    if [[ "${child_parent}" == "${parent_pid}" && "${child_uid}" == "${CURRENT_UID}" ]]; then
      terminate_process_tree "${child_pid}" "${signal_name}" "${parent_pid}"
    fi
  done <<<"${children}"

  parent_parent="$(
    /bin/ps -p "${parent_pid}" -o ppid= 2>/dev/null |
      /usr/bin/tr -d '[:space:]'
  )"
  parent_uid="$(
    /bin/ps -p "${parent_pid}" -o uid= 2>/dev/null |
      /usr/bin/tr -d '[:space:]'
  )"
  [[ "${parent_parent}" == "${expected_parent_pid}" ]] || return
  [[ "${parent_uid}" == "${CURRENT_UID}" ]] || return
  /bin/kill -"${signal_name}" "${parent_pid}" 2>/dev/null || true
}

run_interruptible() {
  local child_status

  "$@" &
  active_child_pid=$!
  if wait "${active_child_pid}"; then
    child_status=0
  else
    child_status=$?
  fi
  active_child_pid=
  return "${child_status}"
}

build_release() {
  cd "${EXAMPLE_DIR}"
  flutter build macos --release
}

reopen_previous_app() {
  local restored_pid

  [[ "${old_app_was_running}" == true ]] || return 0
  if [[ ! -d "${INSTALL_APP}" || -L "${INSTALL_APP}" ]]; then
    warn "The previous app was running but is no longer available to reopen: ${INSTALL_APP}"
    return 1
  fi
  if ! /usr/bin/open "${INSTALL_APP}" >/dev/null 2>&1; then
    warn "The previous app is installed but could not be reopened: ${INSTALL_APP}"
    return 1
  fi

  restored_pid="$(wait_for_installed_process || true)"
  if [[ ! "${restored_pid}" =~ ^[0-9]+$ ]] ||
    ! installed_process_is_stable "${restored_pid}"; then
    warn "The previous app was opened but did not remain running: ${INSTALL_APP}"
    return 1
  fi
}

rollback_installation() {
  local installed_pids
  local pid

  log "Installation failed; restoring the previous app..."

  if path_matches_staging_identity "${INSTALL_APP}"; then
    installed_pids="$(pids_for_executable "${INSTALLED_EXECUTABLE}")"
    while IFS= read -r pid; do
      [[ "${pid}" =~ ^[0-9]+$ ]] || continue
      pid_matches_executable "${pid}" "${INSTALLED_EXECUTABLE}" || continue
      /bin/kill -TERM "${pid}" 2>/dev/null || true
    done <<<"${installed_pids}"

    if ! wait_for_executable_exit "${INSTALLED_EXECUTABLE}"; then
      installed_pids="$(pids_for_executable "${INSTALLED_EXECUTABLE}")"
      while IFS= read -r pid; do
        [[ "${pid}" =~ ^[0-9]+$ ]] || continue
        pid_matches_executable "${pid}" "${INSTALLED_EXECUTABLE}" || continue
        /bin/kill -KILL "${pid}" 2>/dev/null || true
      done <<<"${installed_pids}"
      if ! wait_for_executable_exit "${INSTALLED_EXECUTABLE}"; then
        printf \
          '[yeknom-ui-kit] error: rollback could not stop the failed app process' \
          >&2
        if [[ "${had_existing}" == true ]]; then
          printf '; previous bundle retained at %s' "${backup_app}" >&2
          transaction_dir=
        fi
        printf '\n' >&2
        return
      fi
    fi
  fi

  if [[ "${had_existing}" == true ]]; then
    if path_exists "${backup_app}"; then
      if path_exists "${INSTALL_APP}"; then
        if ! path_matches_staging_identity "${INSTALL_APP}"; then
          printf \
            '[yeknom-ui-kit] error: rollback found an unexpected app at %s; previous bundle retained at %s\n' \
            "${INSTALL_APP}" "${backup_app}" >&2
          transaction_dir=
          return
        fi
        if ! run_installer_command /bin/rm -rf -- "${INSTALL_APP}"; then
          printf \
            '[yeknom-ui-kit] error: rollback could not remove the failed app; previous bundle retained at %s\n' \
            "${backup_app}" >&2
          transaction_dir=
          return
        fi
      fi
      if ! run_installer_command /bin/mv -- "${backup_app}" "${INSTALL_APP}"; then
        printf \
          '[yeknom-ui-kit] error: rollback could not restore the previous app; backup retained at %s\n' \
          "${backup_app}" >&2
        transaction_dir=
        return
      fi
    fi
    reopen_previous_app || true
  elif path_matches_staging_identity "${INSTALL_APP}"; then
    if ! run_installer_command /bin/rm -rf -- "${INSTALL_APP}"; then
      warn "Rollback could not remove the failed first installation: ${INSTALL_APP}"
    fi
  elif path_exists "${INSTALL_APP}"; then
    warn "Rollback left an unexpected app untouched: ${INSTALL_APP}"
  fi
}

cleanup() {
  local exit_code=$?
  trap - EXIT
  trap '' INT TERM

  if [[ "${exit_code}" -ne 0 && "${rollback_needed}" == true ]]; then
    rollback_installation
  elif [[ "${exit_code}" -ne 0 && "${old_app_was_running}" == true ]]; then
    reopen_previous_app || true
  fi

  if [[ -n "${transaction_dir}" ]] &&
    [[ "${transaction_dir}" == "${INSTALL_DIR}/.${PRODUCT_NAME}.transaction."* ]] &&
    path_exists "${transaction_dir}"; then
    if ! run_installer_command /bin/rm -rf -- "${transaction_dir}"; then
      warn "Could not remove transaction directory: ${transaction_dir}"
    fi
  fi

  if [[ "${lock_acquired}" == true ]]; then
    release_install_lock || true
  fi

  exit "${exit_code}"
}

handle_signal() {
  local signal_name=$1
  local signal_exit_code=$2

  trap '' INT TERM
  if [[ "${active_child_pid}" =~ ^[0-9]+$ ]]; then
    log "Received ${signal_name}; stopping the active command..."
    terminate_process_tree "${active_child_pid}" TERM "$$"
    for _ in {1..20}; do
      /bin/kill -0 "${active_child_pid}" 2>/dev/null || break
      /bin/sleep 0.1
    done
    if /bin/kill -0 "${active_child_pid}" 2>/dev/null; then
      terminate_process_tree "${active_child_pid}" KILL "$$"
    fi
    wait "${active_child_pid}" 2>/dev/null || true
    active_child_pid=
  fi
  exit "${signal_exit_code}"
}

[[ "$(uname -s)" == "Darwin" ]] ||
  fail "This installer only supports macOS."
[[ "${EUID}" -ne 0 ]] ||
  fail "Run this script without sudo; it requests administrator access only when required."
command -v flutter >/dev/null 2>&1 ||
  fail "flutter was not found in PATH."
[[ -x /usr/sbin/lsof ]] ||
  fail "lsof is required to verify the launched executable."
[[ -d "${EXAMPLE_DIR}/macos" ]] ||
  fail "The macOS example project is missing: ${EXAMPLE_DIR}/macos"

trap cleanup EXIT
trap 'handle_signal INT 130' INT
trap 'handle_signal TERM 143' TERM

ensure_install_lock_is_available
acquire_install_lock

log "Building ${DISPLAY_NAME} in release mode..."
run_interruptible build_release ||
  fail "The release build failed."
validate_app_bundle "${BUILD_APP}"

configure_installer_privileges
create_transaction_directory

staging_app="${transaction_dir}/${DISPLAY_NAME}.app"
backup_app="${transaction_dir}/previous.app"

log "Preparing the app bundle..."
run_interruptible /usr/bin/ditto "${BUILD_APP}" "${staging_app}" ||
  fail "Could not copy the release build into the staging directory."
validate_app_bundle "${staging_app}"
staging_identity="$(path_identity "${staging_app}" || true)"
[[ "${staging_identity}" =~ ^[0-9]+:[0-9]+$ ]] ||
  fail "Could not record the staged app identity."

if [[ -L "${INSTALL_APP}" ]]; then
  fail "Refusing to replace a symbolic link at ${INSTALL_APP}."
fi
if [[ -e "${INSTALL_APP}" && ! -d "${INSTALL_APP}" ]]; then
  fail "Refusing to replace a non-directory at ${INSTALL_APP}."
fi
if [[ -d "${INSTALL_APP}" ]]; then
  existing_bundle_id="$(bundle_id_for_app "${INSTALL_APP}" || true)"
  [[ "${existing_bundle_id}" == "${BUNDLE_ID}" ]] ||
    fail "Refusing to replace an app with a different bundle identifier at ${INSTALL_APP}."
  had_existing=true
fi

running_pids="$(pids_for_bundle)"
if [[ -n "${running_pids}" ]]; then
  installed_running_pids="$(pids_for_executable "${INSTALLED_EXECUTABLE}")"
  if [[ -n "${installed_running_pids}" ]]; then
    old_app_was_running=true
  fi
  log "Stopping the currently running Catalog..."
  /usr/bin/osascript \
    -e "tell application id \"${BUNDLE_ID}\" to quit" \
    >/dev/null 2>&1 || true

  if ! wait_for_bundle_exit; then
    terminate_bundle_processes
    wait_for_bundle_exit ||
      fail "The running Catalog could not be stopped."
  fi
fi

log "Installing to ${INSTALL_APP}..."
if path_exists "${INSTALL_APP}"; then
  [[ -d "${INSTALL_APP}" && ! -L "${INSTALL_APP}" ]] ||
    fail "The install target changed to an unsafe type: ${INSTALL_APP}"
  existing_bundle_id="$(bundle_id_for_app "${INSTALL_APP}" || true)"
  [[ "${existing_bundle_id}" == "${BUNDLE_ID}" ]] ||
    fail "The install target changed to a different app: ${INSTALL_APP}"
  had_existing=true
  rollback_needed=true
  run_installer_command /bin/mv -- "${INSTALL_APP}" "${backup_app}"
  [[ -d "${backup_app}" && ! -L "${backup_app}" ]] ||
    fail "The previous app changed type while it was being backed up."
  existing_bundle_id="$(bundle_id_for_app "${backup_app}" || true)"
  [[ "${existing_bundle_id}" == "${BUNDLE_ID}" ]] ||
    fail "The previous app changed identity while it was being backed up."
else
  rollback_needed=true
fi

run_installer_command /bin/mv -n -- "${staging_app}" "${INSTALL_DIR}"
path_matches_staging_identity "${INSTALL_APP}" ||
  fail "The install target changed before the staged app could be committed."
validate_app_bundle "${INSTALL_APP}"

log "Launching ${DISPLAY_NAME}..."
/usr/bin/open "${INSTALL_APP}"

started_pid="$(wait_for_installed_process)" ||
  fail "The app was installed, but its process did not start within 10 seconds."
installed_process_is_stable "${started_pid}" ||
  fail "The installed app exited or changed identity during startup."

rollback_needed=false
if [[ "${had_existing}" == true ]]; then
  if ! run_installer_command /bin/rm -rf -- "${backup_app}"; then
    warn "The new app is running, but the previous bundle could not be fully removed: ${backup_app}"
    transaction_dir=
  fi
fi

if [[ -n "${transaction_dir}" ]] && path_exists "${transaction_dir}"; then
  if run_installer_command /bin/rmdir -- "${transaction_dir}"; then
    transaction_dir=
  else
    warn "The new app is running, but the transaction directory could not be removed: ${transaction_dir}"
    transaction_dir=
  fi
fi

release_install_lock ||
  fail "The app is running, but the install lock could not be released."

log "Installed and running (PID ${started_pid}): ${INSTALL_APP}"
