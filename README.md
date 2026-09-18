# certificarte_management

OpenSSL/keytool helpers to convert a Windows PFX into a Java PKCS12 keystore and a cert-only truststore.

(The repository name is spelled `certificarte_management`.)

## Layout

```
scripts/convert_pfx_to_p12.sh
scripts/extract_p12.sh
scripts/extract_pfx.sh
scripts/verify_stores.sh
GROUP.md
README.md
```

## convert_pfx_to_p12.sh

Requires `openssl` and Java `keytool`.

```bash
bash scripts/convert_pfx_to_p12.sh certificate.pfx mykeystore.p12 mytruststore.p12
```

Prompts for the PFX password and the new keystore/truststore passwords.

---

See [GROUP.md](GROUP.md) for sibling repositories. Catalog: https://github.com/nwlterry/nwlterry
