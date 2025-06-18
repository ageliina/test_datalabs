# (C) 2023, 2024 ACRI-ST
#
#
# System : ESA Datalabs
#
# File Name : analysis_services/datalab-generator/docker_templates/Dockerfile.jl
#
# Author : ACRI-ST, CGI
#
# Modified : AV
#
# Creation Date : 2023-08-18
#
# This file is subject to the terms and conditions defined in 'LICENSE.txt',
# which is part of this source code package.
# No part of the package, including this file, may be copied, modified, propagated,
# or distributed except according to the terms contained in 'LICENSE.txt'.

# Try as much as possible to reduce the number of run to speed up the build
ARG JL_BASE_VERSION=stable
ARG REGISTRY=scidockreg.esac.esa.int:62530
FROM ${REGISTRY}/datalabs/jl_base:${JL_BASE_VERSION}
COPY *.* /media/
RUN pip3 install --no-cache-dir -r /media/requirements.txt
RUN mv /media/jupyter_notebook_config.py /etc/ 2>/dev/null ||  echo "No jupyter config found"
RUN mkdir -p /media/notebooks/; chmod +x /media/notebooks/;mv /media/*.ipynb /media/notebooks/ 2>/dev/null ||  echo "No notebooks found"
RUN chmod -R 644 /media/notebooks/*.*;chmod 655 /media/notebooks/

RUN apt list
