#!/bin/bash

gpconfig -s optimizer_analyze_root_partition
gpconfig -s optimizer

gpconfig -c optimizer_analyze_root_partition -v on --masteronly
gpconfig -c optimizer -v on --masteronly

gpstop -a -u

gpconfig -s optimizer_analyze_root_partition
gpconfig -s optimizer
