import * as bcrypt from 'bcrypt';

/**
 * Pure bcrypt hash/compare round-trip test. The email-register /
 * email-login flows rely on the same bcrypt contract the codebase
 * already uses for OTP codes and refresh tokens:
 *
 *   - `hash(plain, rounds)` returns a salted digest
 *   - `compare(plain, digest)` returns true for the correct password
 *   - `compare(wrong, digest)` returns false
 *
 * Breaking this invariant would silently permit any password on login
 * (or lock every user out), so a cheap unit test is worth the couple
 * of ms.
 */
describe('AuthService password bcrypt round-trip', () => {
  const COST = 10;

  it('compares equal plaintext to its own hash as true', async () => {
    const hash = await bcrypt.hash('correct horse battery staple', COST);
    await expect(
      bcrypt.compare('correct horse battery staple', hash),
    ).resolves.toBe(true);
  });

  it('compares a wrong plaintext to a hash as false', async () => {
    const hash = await bcrypt.hash('correct horse battery staple', COST);
    await expect(bcrypt.compare('wrong password', hash)).resolves.toBe(false);
  });

  it('yields different hashes for the same plaintext (salt uniqueness)', async () => {
    const a = await bcrypt.hash('same-input', COST);
    const b = await bcrypt.hash('same-input', COST);
    expect(a).not.toBe(b);
    // And both still verify.
    await expect(bcrypt.compare('same-input', a)).resolves.toBe(true);
    await expect(bcrypt.compare('same-input', b)).resolves.toBe(true);
  });

  it('stamps the configured cost factor into the digest prefix', async () => {
    const h = await bcrypt.hash('x', COST);
    // bcrypt digests look like $2b$<cost>$<22-char-salt><31-char-hash>.
    expect(h).toMatch(/^\$2[aby]\$10\$/);
  });
});
