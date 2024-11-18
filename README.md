# Guide to Decrypt Age Key and Use SOPS

## Prerequisites

- `age` - encryption tool
- `sops` - Mozilla SOPS (Secrets OPerationS)

## 1. Decrypt Age Key File

### 1.1. Decrypt enc.key.txt

```bash
age --decrypt --output key.txt enc.key.txt
```

When prompted, enter your passphrase to decrypt the file.

### 1.2. Set Proper Permissions

Ensure the decrypted key file has the correct permissions:

```bash
chmod 600 key.txt
```

## 2. Using Decrypted Key with SOPS

### 2.1. Set Environment Variable

```bash
export SOPS_AGE_KEY_FILE=./key.txt
```

### 2.2. Decrypt Environment File

Now you can decrypt your encrypted environment file:

```bash
sops --decrypt ./env.enc > .env
```
