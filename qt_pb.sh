#!/usr/bin/env bash

set -eou pipefail

QT_PB_DIR="${HOME}/qt_pb"
QTPYVCP_DIR="${QT_PB_DIR}/qtpyvcp"
PB_DIR="${QT_PB_DIR}/probe_basic"

# Only pyside6 is supported
QT_PB_GIT_OPTS=(--depth=1 --single-branch -b pyside6)

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
		git fetch origin pyside6
		git reset --hard FETCH_HEAD
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

mkdir -p "${HOME}/.local/share/fonts"

if [[ -r "${PB_DIR}/fonts/ProbeBasicBebasMono.ttf" ]] ; then
	cp -L "${PB_DIR}/fonts/ProbeBasicBebasMono.ttf" \
		"${HOME}/.local/share/fonts/"
else
	echo "ERROR: CANNOT FIND FONT FOR PROBE BASIC!"
	exit 1
fi

fc-cache -f

if ! grep -q "source ${QTPYVCP_DIR}/venv/bin/activate" "${HOME}/.bashrc" ; then
	echo "source ${QTPYVCP_DIR}/venv/bin/activate" >> "${HOME}/.bashrc"
fi
