PROJECT=consul
VERSION=1.5.2
SAFE_VERSION=105
PROJECT_NAME=${PROJECT}-${SAFE_VERSION}
PROJECT_VERSION=${VERSION}
DOWNLOAD_SRC=https://github.com/hashicorp/consul/archive/v${VERSION}.tar.gz
LOCAL_SRC_TAR=src.tar.gz
LOCAL_SRC=consul-${VERSION}

USERNAME=consul
GROUPNAME=consul

clone:
	curl -L ${DOWNLOAD_SRC} -o ${LOCAL_SRC_TAR}
	tar -zxf ${LOCAL_SRC_TAR}
	ls

build:
	@ echo 'Print env before building'
	@ bash -c 'env'
	cd ${LOCAL_SRC}; make tools
	cd ${LOCAL_SRC}; make -j 8 dev

package:
	@echo do packagey things!
	mkdir -p ${IPS_BUILD_DIR}/opt/ ${IPS_TMP_DIR}
	cp -r ${PREFIX} ${IPS_BUILD_DIR}/opt

	# SMF
	mkdir -p ${IPS_BUILD_DIR}/lib/svc/manifest/database/
	mkdir -p ${IPS_BUILD_DIR}/lib/svc/method/
	cp smf.xml ${IPS_BUILD_DIR}/lib/svc/manifest/database/${PROJECT_NAME}.xml
	cp method ${IPS_BUILD_DIR}/lib/svc/method/${PROJECT_NAME}

publish: ips-package
ifndef PKGSRVR
	echo "Need to define PKGSRVR, something like http://localhost:10000"
	exit 1
endif
	pkgsend publish -s ${PKGSRVR} -d ${IPS_BUILD_DIR} ${IPS_TMP_DIR}/pkg.pm5.final
	pkgrepo refresh -s ${PKGSRVR}

include ips.mk
