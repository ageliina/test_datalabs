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

# --- DIAGNOSTIC STEP 1: Inspect APT Sources ---
# This will show you exactly what repositories are configured in your base image.
RUN echo "--- DIAGNOSTICS: Contents of /etc/apt/sources.list ---" && \
    cat /etc/apt/sources.list && \
    echo "--- DIAGNOSTICS: Contents of /etc/apt/sources.list.d/ ---" && \
    ls -l /etc/apt/sources.list.d/ && \
    echo "--- DIAGNOSTICS: Contents of all files in /etc/apt/sources.list.d/ ---" && \
    # Using 'find' to handle cases where there might be no files or multiple files
    find /etc/apt/sources.list.d/ -type f -exec sh -c 'echo ">>>> {}"; cat {}' \; || true && \
    echo "--- END DIAGNOSTICS: APT Sources ---"

# --- DIAGNOSTIC STEP 2: Update APT Package Lists ---
# This will perform the update and show you if there are any issues fetching package data.
# We'll use '|| true' to ensure the build doesn't fail *here* if update has warnings/errors.
RUN echo "--- DIAGNOSTICS: Running apt update ---" && \
    apt update || true && \
    echo "--- END DIAGNOSTICS: apt update ---" && \
    \
    # Immediately clean up the cache from the update to keep image size minimal
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# --- DIAGNOSTIC STEP 3: Search for OpenJDK and JRE Packages ---
# This is the most crucial step for identifying available Java packages.
# Added checks for 'jre', 'default-jre', 'openjdk-XX-jre'
RUN echo "--- DIAGNOSTICS: Searching for specific OpenJDK 17 JDK package ---" && \
    apt search openjdk-17-jdk || true && \
    echo "--- DIAGNOSTICS: Checking apt-cache policy for openjdk-17-jdk ---" && \
    apt-cache policy openjdk-17-jdk || true && \
    echo "--- DIAGNOSTICS: Searching for specific OpenJDK 11 JDK package ---" && \
    apt search openjdk-11-jdk || true && \
    echo "--- DIAGNOSTICS: Checking apt-cache policy for openjdk-11-jdk ---" && \
    apt-cache policy openjdk-11-jdk || true && \
    echo "--- DIAGNOSTICS: Searching for default-jdk ---" && \
    apt search default-jdk || true && \
    echo "--- DIAGNOSTICS: Checking apt-cache policy for default-jdk ---" && \
    apt-cache policy default-jdk || true && \
    echo "--- DIAGNOSTICS: Searching for default-jre ---" && \
    apt search default-jre || true && \
    echo "--- DIAGNOSTICS: Checking apt-cache policy for default-jre ---" && \
    apt-cache policy default-jre || true && \
    echo "--- DIAGNOSTICS: Broad search for all openjdk- packages (grep for jdk|jre) ---" && \
    apt search openjdk- | grep -E 'jdk|jre' || true && \
    echo "--- DIAGNOSTICS: Listing all available openjdk-* and default-*jre packages ---" && \
    apt list "openjdk-*" || true && \
    apt list "default-*jre" || true && \
    apt list "jre" || true && \
    echo "--- END DIAGNOSTICS: OpenJDK/JRE Package Search ---"
