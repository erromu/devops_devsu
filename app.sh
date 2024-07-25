#!/bin/bash

set -ex;

python /app/manage.py migrate
python /app/manage.py runserver  0:8000
