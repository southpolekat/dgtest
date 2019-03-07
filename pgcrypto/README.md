# dgtest

Bash scripts to test Deepgreen DB

## Modules
### pgcrypto
#### crypt, gen_salt, md5
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/pgcrypto/pgcrypto_crypt.sh | bash
#### encrypt, decrypt
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/pgcrypto/pgcrypto_encrypt.sh | bash
#### pgp_pub_encrypt, pgp_pub_decrypt, dearmor, pgp_key_id
* curl https://raw.githubusercontent.com/southpolekat/dgtest/master/pgcrypto/pgcrypto_pgp.sh | bash
#### References:
* https://www.postgresonline.com/journal/archives/165-Encrypting-data-with-pgcrypto.html
* https://gpdb.docs.pivotal.io/5170/best_practices/encryption.html
* https://yq.aliyun.com/articles/228268
