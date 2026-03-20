# Serverpod File Uploads Reference

## Table of Contents
- [Upload Process](#upload-process)
- [Server-Side Upload API](#server-side-upload-api)
- [Client-Side Upload](#client-side-upload)
- [Accessing Stored Files](#accessing-stored-files)
- [Cloud Storage Providers](#cloud-storage-providers)

## Upload Process

Serverpod uses a two-step upload: (1) server creates an upload description, (2) client uploads directly.

### Server-Side Upload API

```dart
// Basic upload description
Future<String?> getUploadDescription(Session session, String path) async {
  return await session.storage.createDirectFileUploadDescription(
    storageId: 'public',
    path: path,
  );
}

// With restrictions
Future<String?> getUploadDescription(
  Session session,
  String path,
  int fileSize,
) async {
  return await session.storage.createDirectFileUploadDescription(
    storageId: 'public',
    path: path,
    maxFileSize: 50 * 1024 * 1024,      // 50 MB max
    contentLength: fileSize,              // Exact size validation
    preventOverwrite: true,               // Don't overwrite existing
    expirationDuration: Duration(minutes: 10), // URL validity
  );
}

// Verify upload completed
Future<bool> verifyUpload(Session session, String path) async {
  return await session.storage.verifyDirectFileUpload(
    storageId: 'public',
    path: path,
  );
}
```

### Client-Side Upload

```dart
var uploadDescription = await client.myEndpoint.getUploadDescription('myfile');
if (uploadDescription != null) {
  var uploader = FileUploader(uploadDescription);
  await uploader.upload(myStream);  // Stream or ByteData
  var success = await client.myEndpoint.verifyUpload('myfile');
}
```

**File path conventions:** No leading slashes. Use standard characters: `'profile/$userId/images/avatar.png'`

## Accessing Stored Files

```dart
// Check existence
var exists = await session.storage.fileExists(
  storageId: 'public',
  path: 'my/file/path',
);

// Get public URL
var url = await session.storage.getPublicUrl(
  storageId: 'public',
  path: 'my/file/path',
);

// Retrieve file content
var myByteData = await session.storage.retrieveFile(
  storageId: 'public',
  path: 'my/file/path',
);

// Store file from server
await session.storage.storeFile(
  storageId: 'public',
  path: 'my/file/path',
  byteData: myByteData,
  preventOverwrite: true,
);
```

## Cloud Storage Providers

Default storages (`public` and `private`) use the database. For production, use cloud providers via `pod.addCloudStorage()` before server startup.

### Google Cloud Storage (HMAC)

```bash
dart pub add serverpod_cloud_storage_gcp
```

```dart
import 'package:serverpod_cloud_storage_gcp/serverpod_cloud_storage_gcp.dart' as gcp;

pod.addCloudStorage(
  gcp.GoogleCloudStorage(
    serverpod: pod,
    storageId: 'public',
    public: true,
    region: 'auto',
    bucket: 'my-bucket-name',
    publicHost: 'storage.myapp.com',
  ),
);
```

Credentials in `config/passwords.yaml`:
```yaml
shared:
  HMACAccessKeyId: 'XXXXXXXXXXXXXX'
  HMACSecretKey: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
```

Or env vars: `SERVERPOD_HMAC_ACCESS_KEY_ID`, `SERVERPOD_HMAC_SECRET_KEY`

### Google Cloud Storage (Native JSON API)

Full GCP feature support including `preventOverwrite`.

```dart
import 'package:serverpod_cloud_storage_gcp/serverpod_cloud_storage_gcp.dart' as gcp;

pod.addCloudStorage(
  await gcp.NativeGoogleCloudStorage.create(
    serverpod: pod,
    storageId: 'public',
    public: true,
    bucket: 'my-bucket-name',
    publicHost: 'storage.myapp.com',
  ),
);
```

Credentials in `passwords.yaml`:
```yaml
shared:
  gcpServiceAccount: '{"type":"service_account","project_id":"...","private_key":"...",...}'
```

Alternative: `NativeGoogleCloudStorage.fromApplicationDefaultCredentials(...)` (needs `iam.serviceAccounts.signBlob` IAM permission)

### AWS S3

```bash
dart pub add serverpod_cloud_storage_s3
```

```dart
import 'package:serverpod_cloud_storage_s3/serverpod_cloud_storage_s3.dart' as s3;

pod.addCloudStorage(
  s3.S3CloudStorage(
    serverpod: pod,
    storageId: 'public',
    public: true,
    region: 'us-west-2',
    bucket: 'my-bucket-name',
    publicHost: 'storage.myapp.com',
  ),
);
```

Credentials:
```yaml
shared:
  AWSAccessKeyId: 'XXXXXXXXXXXXXX'
  AWSSecretKey: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
```

### Cloudflare R2

```bash
dart pub add serverpod_cloud_storage_r2
```

```dart
import 'package:serverpod_cloud_storage_r2/serverpod_cloud_storage_r2.dart' as r2;

pod.addCloudStorage(
  r2.R2CloudStorage(
    serverpod: pod,
    storageId: 'public',
    public: true,
    bucket: 'my-bucket-name',
    accountId: 'your-cloudflare-account-id',
    publicHost: 'storage.myapp.com',
  ),
);
```

Credentials:
```yaml
shared:
  R2AccessKeyId: 'XXXXXXXXXXXXXX'
  R2SecretKey: 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
```
