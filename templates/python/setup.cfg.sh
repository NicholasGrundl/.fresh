#!/bin/bash

# Repository name
PACKAGE_NAME="mypackage"

# Metadata
VERSION=`PYTHONPATH=src python -c "import $PACKAGE_NAME; print('.'.join(map(str,$PACKAGE_NAME.__version__)))"`
AUTHOR=`PYTHONPATH=src python -c "import $PACKAGE_NAME; print($PACKAGE_NAME.__author__)"`
AUTHOR_EMAIL=`PYTHONPATH=src python -c "import $PACKAGE_NAME; print($PACKAGE_NAME.__author_email__)"`
MAINTAINER=`PYTHONPATH=src python -c "import $PACKAGE_NAME; print($PACKAGE_NAME.__maintainer__)"`
MAINTAINER_EMAIL=`PYTHONPATH=src python -c "import $PACKAGE_NAME; print($PACKAGE_NAME.__maintainer_email__)"`
DESCRIPTION=`PYTHONPATH=src python -c "import $PACKAGE_NAME; print($PACKAGE_NAME.__doc__)"`
REQUIRES=`PYTHONPATH=src python -c "list(map(print,['\t'+line.strip() for line in open('requirements.txt', 'r').readlines()]))"`

cat <<EOF > setup.cfg
[metadata]
name = $PACKAGE_NAME
version = ${VERSION}
author = ${AUTHOR}
author_email = ${AUTHOR_EMAIL}
maintainer = ${MAINTAINER}
maintainer_email = ${MAINTAINER_EMAIL}
description = ${DESCRIPTION}
license = Apache License 2.0
url = https://github.com/NicholasGrundl/$PACKAGE_NAME

[options]
packages_dir = 
	=src
packages = find:
include_package_data = True
install_requires =
${REQUIRES}

[options.package_data]
* = *.json, *.yaml, *.csv

[options.packages.find]
where=src

[coverage:run]
branch = True
EOF
