#!/usr/bin/env bash

set -eou pipefail

QT_PB_DIR="${HOME}/qt_pb"
QTPYVCP_DIR="${QT_PB_DIR}/qtpyvcp"
PB_DIR="${QT_PB_DIR}/probe_basic"

QT_PB_BRANCH="pyside6"
QT_PB_GIT_OPTS=(--depth=1 --single-branch -b "${QT_PB_BRANCH}")

mkdir -p "${QT_PB_DIR}"

for i in qtpyvcp probe_basic ; do
	GIT_DIR="${QT_PB_DIR}/${i}"
	GIT_SRC="https://github.com/kcjengr/${i}.git"

	if [[ ! -d "${GIT_DIR}" ]] ; then
		git clone "${QT_PB_GIT_OPTS[@]}" "${GIT_SRC}" "${GIT_DIR}"
	else
		cd "${GIT_DIR}"
		git clean -dxf
		git pull
	fi
done

setup_qtpyvcp() {
	cd "${QTPYVCP_DIR}"
	python -m venv venv --system-site-packages
	source "${QTPYVCP_DIR}/venv/bin/activate"
	pip install hiyapyco
	pip install -e "${QTPYVCP_DIR}"
	qcompile "${QTPYVCP_DIR}"
	qnative
}

setup_probe_basic() {
	cd "${PB_DIR}"
	pip install -e "${PB_DIR}"
	qcompile "${PB_DIR}"
}

setup_qtpyvcp

setup_probe_basic

if ! grep -q "source ${QTPYVCP_DIR}/venv/bin/activate" "${HOME}/.bashrc" ; then
	echo "source ${QTPYVCP_DIR}/venv/bin/activate" >> "${HOME}/.bashrc"
fi
