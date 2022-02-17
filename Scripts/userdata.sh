#!/bin/bash
apt-get update
apt-get install nginx -yum
systemctl restart nginx
systemctl enable nginx