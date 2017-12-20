#!/bin/bash
#

sudo docker run \
	-v /opt/projects/mdf/dev/postgresql/conf:/rnel/postgresql/conf \
	-v /opt/projects/mdf/dev/postgresql/db:/rnel/postgresql/db \
	-v /opt/projects/mdf/dev/postgresql/log:/rnel/postgresql/log \
        -it rnel_postgresql:1.0 \
        bash

