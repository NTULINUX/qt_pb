#!/usr/bin/env bash

set -eou pipefail

QT_PB_DIR="${HOME}/qt_pb"
QTPYVCP_DIR="${QT_PB_DIR}/qtpyvcp"
PB_DIR="${QT_PB_DIR}/probe_basic"

QT_PB_BRANCH="pyside6"
QT_PB_GIT_OPTS=(--depth=1 --single-branch -b "${QT_PB_BRANCH}")

mkdir -p "${QT_PB_DIR}"

for i in qtpyvcp probe_basic ; do
	if [[ "${i}" == "qtpyvcp" ]] ; then
		GIT_DIR="${QTPYVCP_DIR}"
	elif [[ "${i}" == "probe_basic" ]] ; then
		GIT_DIR="${PB_DIR}"
	fi

	GIT_SRC="https://github.com/kcjengr/${i}.git"

	if [[ ! -d "${GIT_DIR}" ]] ; then
		git clone "${QT_PB_GIT_OPTS[@]}" "${GIT_SRC}" "${GIT_DIR}"
	else
		cd "${GIT_DIR}"
		git clean -dxf
		git fetch origin "${QT_PB_BRANCH}"
		git reset --hard "origin/${QT_PB_BRANCH}"
	fi
done

cd "${QTPYVCP_DIR}"
python -m venv venv --system-site-packages
# shellcheck disable=SC1091
source "${QTPYVCP_DIR}/venv/bin/activate"
pip install --upgrade pip setuptools wheel hiyapyco
pip install -e "${QTPYVCP_DIR}"
qcompile "${QTPYVCP_DIR}"
qnative

cd "${PB_DIR}"
pip install -e "${PB_DIR}"
qcompile "${PB_DIR}"

if ! grep -q "source ${QTPYVCP_DIR}/venv/bin/activate" "${HOME}/.bashrc" ; then
	echo "source ${QTPYVCP_DIR}/venv/bin/activate" >> "${HOME}/.bashrc"
fi
