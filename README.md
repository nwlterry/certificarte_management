# certificarte_management

OpenSSL/keytool helpers for converting Windows PFX certificates into Java PKCS12 keystore and truststore files.

(The repository name is spelled `certificarte_management`.)

## Scripts

| File | Purpose |
| --- | --- |
| `convert_pfx_to_p12.sh` | Extract key + cert from a PFX, then create a PKCS12 keystore and a cert-only truststore. |
| `extract_p12.sh` | Extract material from a P12. |
| `extract_pfx.sh` | Extract material from a PFX. |
| `verify_stores.sh` | Verify generated stores. |

## convert_pfx_to_p12.sh

Requires `openssl` and Java `keytool`.

```bash
bash convert_pfx_to_p12.sh certificate.pfx mykeystore.p12 mytruststore.p12
```

Prompts for the PFX password and the new keystore/truststore passwords. Temp PEMs are cleaned up on exit.
