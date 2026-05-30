import { S3Client, HeadObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import fs from "fs";
import path from "path";
import mime from "mime-types";

// Initialize R2 Client
const s3 = new S3Client({
  region: "auto",
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

const BUCKET_NAME = "fakejournalartifacts";
const LOCAL_DIR = "_dist/"; // Path to your local directory

// Helper to recursively get all files in a directory
function getFiles(dir) {
  const subdirs = fs.readdirSync(dir);
  const files = subdirs.map((subdir) => {
    const res = path.resolve(dir, subdir);
    return fs.statSync(res).isDirectory() ? getFiles(res) : res;
  });
  return files.flat();
}

async function syncToR2() {
  const absoluteLocalDir = path.resolve(LOCAL_DIR);
  const files = getFiles(absoluteLocalDir);

  for (const filePath of files) {
    // Create the relative key name for R2 (e.g., "images/pic.png")
    const relativeKey = path.relative(absoluteLocalDir, filePath).replace(/\\/g, "/");
    const localStats = fs.statSync(filePath);
    const localMtime = localStats.mtime;

    let shouldUpload = false;

    try {
      // Check if file exists on R2 and get its metadata
      const remoteMeta = await s3.send(
        new HeadObjectCommand({ Bucket: BUCKET_NAME, Key: relativeKey })
      );
      
      const remoteMtime = new Date(remoteMeta.LastModified);

      // rsync -u logic: Upload only if local file is newer than remote file
      if (localMtime > remoteMtime) {
        console.log(`[UPDATE] ${relativeKey} (Local is newer)`);
        shouldUpload = true;
      } else {
        console.log(`[SKIP] ${relativeKey} (Remote is up-to-date)`);
      }
    } catch (error) {
      // If 404, the file doesn't exist on R2 yet, so we must upload it
      if (error.name === "NotFound" || error.$metadata?.httpStatusCode === 404) {
        console.log(`[NEW] ${relativeKey}`);
        shouldUpload = true;
      } else {
        console.error(`Error checking ${relativeKey}:`, error);
        continue;
      }
    }

    if (shouldUpload) {
      const fileStream = fs.createReadStream(filePath);
      const contentType = mime.lookup(filePath) || "application/octet-stream";

      try {
        await s3.send(
          new PutObjectCommand({
            Bucket: BUCKET_NAME,
            Key: relativeKey,
            Body: fileStream,
            ContentType: contentType,
          })
        );
        console.log(`[SUCCESS] Uploaded ${relativeKey}`);
      } catch (uploadError) {
        console.error(`[FAILED] Uploading ${relativeKey}:`, uploadError);
      }
    }
  }
}

syncToR2();
