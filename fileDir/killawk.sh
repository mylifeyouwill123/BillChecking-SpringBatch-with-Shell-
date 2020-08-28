#!/bin/bash
ps -ef | grep awk | grep -v grep | awk '{print "kill -9 "$2}'|sh
