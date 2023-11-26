#!/bin/bash

show_help() {
  echo "Usage: $(basename "$0") db_file -c command"
  echo "Commands:"
  echo "  add_data - adds some data to existing database"
  echo "    --count_project NUM - number of created projects"
  echo "    --count_section NUM - number of created sections in a project"
  echo "    --count_item NUM    - number of created items in a section"
  echo "  clear_db - drops all db tables"
}

exec_sql() {
  sqlite3 "${DB_FILE}" "${1}"
}

get_time() {
  date +%s%3N
}

add_project() {
  local NAME="TEST_${1}"
  local CREATE_TIME
  CREATE_TIME=$(get_time)
  exec_sql "
       INSERT INTO project
       (name, details, created_date, last_access_date)
       VALUES('${NAME}', 'TEST_DETAILS', $CREATE_TIME, $CREATE_TIME);
       SELECT last_insert_rowid();"
}

add_section() {
  local NAME="SEC_PR${1}/${2}"
  local CREATE_TIME
  CREATE_TIME=$(get_time)
  exec_sql "INSERT INTO section
      (project_id, name, details, operator_name, created_date)
      VALUES(${1}, '${NAME}', '${NAME}_DET', 'X', $CREATE_TIME);
      SELECT last_insert_rowid();"
}

add_scanned_item() {
  local CREATE_TIME
  CREATE_TIME=$(get_time)
  exec_sql "INSERT INTO scanned_item
      (section_id, barcode, created_date, updated_date, count)
      VALUES(${1}, '12345678', $CREATE_TIME, $CREATE_TIME, 1);
      SELECT last_insert_rowid();"
}

create_test_data() {
  local ADDED_PROJECT_COUNT=$1
  local ADDED_SECTION_COUNT=$2
  local ADDED_SCAN_ITEM_COUNT=$3
  echo -n "Will create ${ADDED_PROJECT_COUNT} projects, with ${ADDED_SECTION_COUNT} sections "
  echo "with ${ADDED_SCAN_ITEM_COUNT} items"
  for p in $(seq 1 "$ADDED_PROJECT_COUNT"); do
    projectId=$(add_project "$p")
    echo -n "Created new project $projectId ... "
    for s in $(seq 1 "$ADDED_SECTION_COUNT"); do
      sectionId=$(add_section "$projectId" "$s")
      echo -n " added section $sectionId ..."
      for _ in $(seq 1 "$ADDED_SCAN_ITEM_COUNT"); do
        add_scanned_item "$sectionId" &>/dev/null
      done
      echo " created $ADDED_SCAN_ITEM_COUNT items."
    done
  done
}

clear_db() {
  exec_sql "
      drop table if exists preferences;
      drop table if exists project;
      drop table if exists scanned_item;
      drop table if exists section;"
}

POSITIONAL_ARGUMENTS=()

ADDED_PROJECT_COUNT=1
ADDED_SECTION_COUNT=1
ADDED_SCAN_ITEM_COUNT=1

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -c | --command)
    command="$2"
    shift
    ;;
  --count_project)
    ADDED_PROJECT_COUNT="$2"
    shift
    ;;
  --count_section)
    ADDED_SECTION_COUNT="$2"
    shift
    ;;
  --count_item)
    ADDED_SCAN_ITEM_COUNT="$2"
    shift
    ;;
  *) POSITIONAL_ARGUMENTS+=("$1") ;;
  esac
  shift
done

set -- "${POSITIONAL_ARGUMENTS[@]}"

DB_FILE=$1

echo "Using ${DB_FILE}"

if [ ! -f "${DB_FILE}" ]; then
  echo "File ${DB_FILE} does not exist"
  exit 1
fi

if [ "" == "$command" ]; then
  echo "Command missing."
  show_help
  exit 1
fi

if [ "clear_db" == "${command}" ]; then
  clear_db
elif [ "add_data" == "${command}" ]; then
  create_test_data "${ADDED_PROJECT_COUNT}" "${ADDED_SECTION_COUNT}" "${ADDED_SCAN_ITEM_COUNT}"
else
  echo "Unknown command: ${command}"
  show_help
  exit 1
fi
