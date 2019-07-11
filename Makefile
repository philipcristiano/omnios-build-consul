PROJECT=consul
VERSION=1.5.2
PROJECT_NAME=${PROJECT}
PROJECT_VERSION=${VERSION}
DOWNLOAD_SRC=https://github.com/hashicorp/consul/archive/v${VERSION}.tar.gz
LOCAL_SRC_TAR=src.tar.gz
LOCAL_SRC=consul-${VERSION}

USERNAME=consul
GROUPNAME=consul
BUILD_OUTPUT_DIR=go

clone:
	curl -L ${DOWNLOAD_SRC} -o ${LOCAL_SRC_TAR}
	tar -zxf ${LOCAL_SRC_TAR}
	ls

build:
	@ echo 'Print env before building'
	@ bash -c 'env'
	cd ${LOCAL_SRC}; make -j 8 tools
	cd ${LOCAL_SRC}; make -j 8 dev-build

package:
	@echo do packagey things!
	mkdir -p ${IPS_BUILD_DIR}/opt/consul/bin ${IPS_TMP_DIR}

	cp -r ${BUILD_OUTPUT_DIR}/bin/consul ${IPS_BUILD_DIR}/opt/consul/bin

	# SMF
	mkdir -p ${IPS_BUILD_DIR}/lib/svc/manifest/database/
	mkdir -p ${IPS_BUILD_DIR}/lib/svc/method/
	mkdir -p ${IPS_BUILD_DIR}/etc/consul.d
	mkdir -p ${IPS_BUILD_DIR}/var/consul
	# cp smf.xml ${IPS_BUILD_DIR}/lib/svc/manifest/database/${PROJECT_NAME}.xml
	# cp method ${IPS_BUILD_DIR}/lib/svc/method/${PROJECT_NAME}

publish: ips-package
ifndef PKGSRVR
	echo "Need to define PKGSRVR, something like http://localhost:10000"
	exit 1
endif
	pkgsend publish -s ${PKGSRVR} -d ${IPS_BUILD_DIR} ${IPS_TMP_DIR}/pkg.pm5.final
	pkgrepo refresh -s ${PKGSRVR}

include ips.mk
