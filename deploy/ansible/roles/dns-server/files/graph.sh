#!/bin/bash

# https://github.com/RaymiiOrg/bind-gnuplot-reports

awk '{ print $3 }' /var/log/named/queries.log | sort | uniq -c | sort -n | tail -n 20 > /root/dns-data

gnuplot < plot.gplt
