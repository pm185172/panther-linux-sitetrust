#!/bin/bash

BASEPATH="/home/pcrfuel/Radiant/FastPoint"
LOGPATH="${BASEPATH}/Log"
AUDITPATH="${BASEPATH}/Audit"
ARCHIVEPATH="${AUDITPATH}/Archive"

verifypaths() {
    if [ -d ${LOGPATH} ]; then
        chmod 774 ${LOGPATH}
    else
        mkdir -m774 -p ${LOGPATH}
        chown pcrfuel:pcrfuel ${LOGPATH}
    fi
    if [ -d ${AUDITPATH} ]; then
        chmod 774 ${AUDITPATH}
    else
        mkdir -m774 -p ${AUDITPATH}
        chown pcrfuel:pcrfuel ${AUDITPATH}
    fi
    if [ -d ${ARCHIVEPATH} ]; then
        chmod 774 ${ARCHIVEPATH}
    else
        mkdir -m774 -p ${ARCHIVEPATH}
        chown pcrfuel:pcrfuel ${ARCHIVEPATH}
    fi
}

if [ "$#" -eq 0 ]; then
    su -c "/home/sitetrust/SecurityService/Ncr.SiteTrust.SecurityService" sitetrust
else
    echo "Usage: $0"
    exit
fi
