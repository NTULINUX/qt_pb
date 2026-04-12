#!/usr/bin/env bash

set -eou pipefail

QT_PB_DIR="${HOME}/qt_pb"
QTPYVCP_DIR="${HOME}/qt_pb/qtpyvcp"
PB_DIR="${HOME}/qt_pb/probe_basic"

QT_PB_BRANCH="pyside6"
QT_PB_GIT_OPTS=(--depth=1 --single-branch -b "${QT_PB_BRANCH}")

mkdir -p "${QT_PB_DIR}"

if [[ ! -d "${QT_PB_DIR}/qtpyvcp" ]] ; then
	git clone "${QT_PB_GIT_OPTS[@]}" \
		https://github.com/kcjengr/qtpyvcp.git \
		"${QTPYVCP_DIR}"
else
	cd "${QTPYVCP_DIR}"
	git pull
fi

if [[ ! -d "${QT_PB_DIR}/probe_basic" ]] ; then
	git clone "${QT_PB_GIT_OPTS[@]}" \
		https://github.com/kcjengr/probe_basic.git \
		"${PB_DIR}"
else
	cd "${PB_DIR}"
	git pull
fi

setup_qtpyvcp() {
	rm -rf "${QTPYVCP_DIR:?}/venv"
	cd "${QTPYVCP_DIR}"
	python -m venv venv --system-site-packages
	source "${QTPYVCP_DIR}/venv/bin/activate"
	pip install hiyapyco
	pip install -e "${QT_PB_DIR}/qtpyvcp"
	qcompile "${QTPYVCP_DIR}"
	qnative
}

setup_probe_basic() {
	cd "${QT_PB_DIR}/probe_basic"
	pip install -e "${QT_PB_DIR}/probe_basic"
	qcompile "${PB_DIR}"
}

setup_qtpyvcp

setup_probe_basic

if ! grep -q "source ${QTPYVCP_DIR}/venv/bin/activate" ~/.bashrc ; then
	echo "source ${QTPYVCP_DIR}/venv/bin/activate" >> "${HOME}/.bashrc"
fi
