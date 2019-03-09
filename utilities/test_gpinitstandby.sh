#!/bin/bash

set -x

### Add a backup standby master on host smdw
gpinitstandby -a -s smdw
### -a : no prompt
### -s <standby_hostname>

### Show standby information
gpstate -f

### Remove standby
gpinitstandby -a -r

gpstate -f
