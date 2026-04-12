#!/usr/bin/env bash

set -eou pipefail

QT_PB_DIR="${HOME}/qt_pb"
QTPYVCP_DIR="${QT_PB_DIR}/qtpyvcp"
PB_DIR="${QT_PB_DIR}/probe_basic"

QT_PB_BRANCH="pyside6"
QT_PB_GIT_OPTS=(--depth=1 --single-branch -b "${QT_PB_BRANCH}")

mkdir -p "${QT_PB_DIR}"

if [[ ! -d "${QTPYVCP_DIR}" ]] ; then
	git clone "${QT_PB_GIT_OPTS[@]}" \
		https://github.com/kcjengr/qtpyvcp.git \
		"${QTPYVCP_DIR}"
else
	cd "${QTPYVCP_DIR}"
	git pull
fi

if [[ ! -d "${PB_DIR}" ]] ; then
	git clone "${QT_PB_GIT_OPTS[@]}" \
		https://github.com/kcjengr/probe_basic.git \
		"${PB_DIR}"
else
	cd "${PB_DIR}"
	git pull
fi

setup_qtpyvcp() {
	cd "${QTPYVCP_DIR}"
	git clean -dxf
	python -m venv venv --system-site-packages
	source "${QTPYVCP_DIR}/venv/bin/activate"
	pip install hiyapyco
	pip install -e "${QTPYVCP_DIR}"
	qcompile "${QTPYVCP_DIR}"
	qnative
}

setup_probe_basic() {
	cd "${PB_DIR}"
	git clean -dxf
	pip install -e "${PB_DIR}"
	qcompile "${PB_DIR}"
}

setup_qtpyvcp

setup_probe_basic

if ! grep -q "source ${QTPYVCP_DIR}/venv/bin/activate" "${HOME}/.bashrc" ; then
	echo "source ${QTPYVCP_DIR}/venv/bin/activate" >> "${HOME}/.bashrc"
fi
