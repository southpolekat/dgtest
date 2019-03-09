#!/bin/bash

set -x

### Note: the current DB cluster has standby configured on host smdw
### Current: master on mdw, standby on smdw

### Stop the DB cluster 
gpstop -a

### Activate standby as master on smdw
ssh smdw 'export PGPORT=5432; gpactivatestandby -a -f -d /data/master/gpseg-1'
### Current: master on smdw, no standby

### Resume the configuration 

### backup the master directory on mdw
rm -rf ${MASTER_DATA_DIRECTORY}.bak
mv ${MASTER_DATA_DIRECTORY} ${MASTER_DATA_DIRECTORY}.bak

### configure mdw as standby
ssh smdw 'gpinitstandby -a -s mdw'
### Current: master on smdw, standby on mdw

### show standby configuration
ssh smdw 'gpstate -f'

### stop the DB cluster
ssh smdw 'gpstop -a'

### activate standby as master on mdw  
export PGPORT=5432
gpactivatestandby -a -f -d ${MASTER_DATA_DIRECTORY}
### Current: master on mdw, no standby

### backup the master directory on smdw
ssh smdw 'rm -rf /data/master/gpseg-1.bak'
ssh smdw 'mv /data/master/gpseg-1 /data/master/gpseg-1.bak'

### configure smdw as standby
gpinitstandby -a -s smdw
### Current: master on mdw, standby on smdw

gpstate -f
