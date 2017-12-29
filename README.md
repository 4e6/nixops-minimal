# nixops-minimal

Minimal nixops configurations

## Google Compute Cloud

GCE authentication requires following env variables:

* `GCE_PROJECT` - project id `my-project-xxxxxx`
* `GCE_SERVICE_ACCOUNT` - IAM service account id `xxxxxx@my-project-xxxxxxx.iam.gserviceaccount.com`
* `ACCESS_KEY_PATH` - path to key in PEM format

GCE generates private key in the PKCS12 format, you'll need to convert the key to PEM format by running the following command:

```
$ openssl pkcs12 -in pkey.p12 -passin pass:notasecret -nodes -nocerts | openssl rsa -out pkey.pem
```

Create and deploy to GCE with environment variables set:

```
nixops create -d mini gce-minimal.nix
nixops deploy -d mini
```
