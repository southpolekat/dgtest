# dgtest

Bash scripts to test Deepgreen DB

* Speed test: Greenplum vs Deepgreen
 * curl https://raw.githubusercontent.com/southpolekat/dgtest/master/vitesse_enable.sh | bash

## [Features](http://vitessedata.com/products/deepgreen-db/features/deepgreen-db-matrix/)
### [Fast Decimal](http://vitessedata.com/products/deepgreen-db/features/deepgreen-db-decimal/)
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/fast_decimal.sh | bash

### [Compression lz4 and zstd](http://vitessedata.com/products/deepgreen-db/features/deepgreen-db-z/)
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/compression.sh | bash

### [PAX column store](http://vitessedata.com/products/deepgreen-db/features/deepgreen-db-pax/)
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/pax_column_store.sh | bash

### [Sampling](http://vitessedata.com/products/deepgreen-db/features/deepgreen-db-sample/)
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/sampling.sh | bash

### [JSON](http://vitessedata.com/products/deepgreen-db/features/deepgreen-db-json/)
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/json.sh | bash

## [Xdrive](http://vitessedata.com/products/deepgreen-db/xdrive/)
### [FS Plugin](http://vitessedata.com/products/deepgreen-db/xdrive/plugin-fs/)
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/xdrive_fs.sh | bash

## SQL Commands
### COPY
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/sql_copy.sh | bash

## Modules
### pgcrypto
#### crypt, gen_salt, md5
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/pgcrypto_crypt.sh | bash
#### encrypt, decrypt
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/pgcrypto_encrypt.sh | bash
#### References:
* https://www.postgresonline.com/journal/archives/165-Encrypting-data-with-pgcrypto.html
* https://yq.aliyun.com/articles/228268
