// Prints a SQL INSERT for the users table. Same PBKDF2-SHA256 scheme
// the Worker verifies (see src/auth.ts).
// Usage: node scripts/create-admin.mjs admin@example.com "strong-password"
import { randomBytes, pbkdf2Sync } from 'node:crypto';

const [email, password] = process.argv.slice(2);
if (!email || !password) {
  console.error('usage: node scripts/create-admin.mjs <email> <password>');
  process.exit(1);
}
if (email.includes("'")) {
  console.error('email must not contain a single quote');
  process.exit(1);
}
const salt = randomBytes(16).toString('base64');
const hash = pbkdf2Sync(password, Buffer.from(salt, 'base64'), 100000, 32, 'sha256').toString(
  'base64',
);
const id = randomBytes(8).toString('hex');
console.log(
  `INSERT INTO users (id, email, password_hash) VALUES ('${id}', '${email}', 'pbkdf2$100000$${salt}$${hash}');`,
);
