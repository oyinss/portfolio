/// Phase 5 auth: PBKDF2 password verify + HMAC-SHA256 session tokens.
/// Stored hash format: `pbkdf2$<iterations>$<salt b64>$<hash b64>` (see scripts/create-admin.mjs).
import type { Context, Next } from 'hono';

const enc = new TextEncoder();

function b64encode(bytes: Uint8Array): string {
  let s = '';
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function b64decode(s: string): Uint8Array {
  const norm = s.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(norm + '='.repeat((4 - (norm.length % 4)) % 4));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

function timingSafeEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
  return diff === 0;
}

export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const parts = stored.split('$');
  if (parts.length !== 4 || parts[0] !== 'pbkdf2') return false;
  const iterations = Number(parts[1]);
  if (!Number.isSafeInteger(iterations) || iterations <= 0) return false;
  const salt = b64decode(parts[2]);
  const expected = b64decode(parts[3]);
  const key = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, [
    'deriveBits',
  ]);
  const derived = new Uint8Array(
    await crypto.subtle.deriveBits(
      { name: 'PBKDF2', hash: 'SHA-256', salt: salt as BufferSource, iterations },
      key,
      expected.length * 8,
    ),
  );
  return timingSafeEqual(derived, expected);
}

/// Hashes a new password with the same PBKDF2-SHA256 scheme as
/// scripts/create-admin.mjs (100k iterations, 16-byte salt, 32-byte hash).
export async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await crypto.subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, [
    'deriveBits',
  ]);
  const derived = new Uint8Array(
    await crypto.subtle.deriveBits(
      { name: 'PBKDF2', hash: 'SHA-256', salt: salt as BufferSource, iterations: 100000 },
      key,
      256,
    ),
  );
  return `pbkdf2$100000$${b64encode(salt)}$${b64encode(derived)}`;
}

async function hmacSign(data: string, secret: string): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, [
    'sign',
  ]);
  return new Uint8Array(await crypto.subtle.sign('HMAC', key, enc.encode(data)));
}

export async function issueToken(userId: string, secret: string, ttlSec = 7 * 86400): Promise<string> {
  const payload = b64encode(enc.encode(JSON.stringify({ sub: userId, exp: Math.floor(Date.now() / 1000) + ttlSec })));
  const sig = b64encode(await hmacSign(payload, secret));
  return `${payload}.${sig}`;
}

/// Returns the user id (`sub`) or null when invalid/expired.
export async function verifyToken(token: string, secret: string): Promise<string | null> {
  const parts = token.split('.');
  if (parts.length !== 2) return null;
  const expected = await hmacSign(parts[0], secret);
  if (!timingSafeEqual(b64decode(parts[1]), expected)) return null;
  try {
    const payload = JSON.parse(new TextDecoder().decode(b64decode(parts[0]))) as {
      sub?: string;
      exp?: number;
    };
    if (!payload.sub || typeof payload.exp !== 'number') return null;
    if (payload.exp < Math.floor(Date.now() / 1000)) return null;
    return payload.sub;
  } catch {
    return null;
  }
}

export async function requireAdmin(c: Context, next: Next) {
  const secret = (c.env as Record<string, string | undefined>).ADMIN_TOKEN;
  if (!secret) return c.json({ error: 'auth not configured' }, 500);
  const header = c.req.header('Authorization') ?? '';
  const match = /^Bearer (.+)$/.exec(header);
  if (!match) return c.json({ error: 'unauthorized' }, 401);
  const sub = await verifyToken(match[1], secret);
  if (!sub) return c.json({ error: 'invalid or expired token' }, 401);
  c.set('adminId', sub);
  await next();
}
