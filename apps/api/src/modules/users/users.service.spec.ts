import { UsersService } from './users.service';
import { CredentialType } from '../../common/enums';

describe('UsersService.computeCompleteness', () => {
  const dob = new Date('1990-01-01');

  it('returns 0 for an empty profile', () => {
    expect(
      UsersService.computeCompleteness(
        {
          dateOfBirth: undefined,
          name: '',
          username: undefined,
          avatarUrl: undefined,
          tutorialCompletedAt: undefined,
        },
        [],
        0,
      ),
    ).toBe(0);
  });

  it('scores each contract-defined field once', () => {
    const pct = UsersService.computeCompleteness(
      {
        dateOfBirth: dob, // +10
        name: 'Alice', // +15
        username: 'alice', // +15
        avatarUrl: 'https://x/y.png', // +15
        tutorialCompletedAt: new Date(), // +10
      },
      [
        { type: CredentialType.PHONE }, // +10
        { type: CredentialType.EMAIL }, // +10
      ],
      5, // interests >= 3 → +15
    );
    expect(pct).toBe(100);
  });

  it('caps at 100', () => {
    const pct = UsersService.computeCompleteness(
      {
        dateOfBirth: dob,
        name: 'A',
        username: 'a',
        avatarUrl: 'u',
        tutorialCompletedAt: new Date(),
      },
      [
        { type: CredentialType.PHONE },
        { type: CredentialType.EMAIL },
        // duplicate rows should not double-count thanks to .some()
        { type: CredentialType.PHONE },
      ],
      99,
    );
    expect(pct).toBeLessThanOrEqual(100);
  });

  it('does not credit phone when only email present', () => {
    const pct = UsersService.computeCompleteness(
      {
        dateOfBirth: undefined,
        name: 'A',
        username: undefined,
        avatarUrl: undefined,
        tutorialCompletedAt: undefined,
      },
      [{ type: CredentialType.EMAIL }],
      0,
    );
    // name +15 + email +10 = 25
    expect(pct).toBe(25);
  });

  it('does not credit interests below the 3-count threshold', () => {
    const pct = UsersService.computeCompleteness(
      {
        dateOfBirth: undefined,
        name: '',
        username: undefined,
        avatarUrl: undefined,
        tutorialCompletedAt: undefined,
      },
      [],
      2,
    );
    expect(pct).toBe(0);
  });
});

describe('UsersService.computeMissingFields', () => {
  const emptyUser = {
    dateOfBirth: undefined,
    name: '',
    username: undefined,
    avatarUrl: undefined,
    tutorialCompletedAt: undefined,
  };

  it('returns all 8 fields for a brand-new user', () => {
    expect(UsersService.computeMissingFields(emptyUser, [], 0)).toEqual([
      'dob',
      'display_name',
      'username',
      'avatar_url',
      'interests',
      'primary_phone_verified',
      'primary_email_verified',
      'tutorial_completed',
    ]);
  });

  it('omits dob when present', () => {
    const missing = UsersService.computeMissingFields(
      { ...emptyUser, dateOfBirth: new Date('1990-01-01') },
      [],
      0,
    );
    expect(missing).not.toContain('dob');
  });

  it('omits display_name when name non-empty', () => {
    const missing = UsersService.computeMissingFields(
      { ...emptyUser, name: 'Alice' },
      [],
      0,
    );
    expect(missing).not.toContain('display_name');
  });

  it('still reports display_name when name is whitespace only', () => {
    const missing = UsersService.computeMissingFields(
      { ...emptyUser, name: '   ' },
      [],
      0,
    );
    expect(missing).toContain('display_name');
  });

  it('omits username when set', () => {
    const missing = UsersService.computeMissingFields(
      { ...emptyUser, username: 'alice' },
      [],
      0,
    );
    expect(missing).not.toContain('username');
  });

  it('omits avatar_url when set', () => {
    const missing = UsersService.computeMissingFields(
      { ...emptyUser, avatarUrl: 'https://x/y.png' },
      [],
      0,
    );
    expect(missing).not.toContain('avatar_url');
  });

  it('omits interests only at >= 3 declared', () => {
    expect(
      UsersService.computeMissingFields(emptyUser, [], 2),
    ).toContain('interests');
    expect(
      UsersService.computeMissingFields(emptyUser, [], 3),
    ).not.toContain('interests');
  });

  it('omits primary_phone_verified when phone credential present', () => {
    const missing = UsersService.computeMissingFields(
      emptyUser,
      [{ type: CredentialType.PHONE }],
      0,
    );
    expect(missing).not.toContain('primary_phone_verified');
    expect(missing).toContain('primary_email_verified');
  });

  it('omits primary_email_verified when email credential present', () => {
    const missing = UsersService.computeMissingFields(
      emptyUser,
      [{ type: CredentialType.EMAIL }],
      0,
    );
    expect(missing).not.toContain('primary_email_verified');
    expect(missing).toContain('primary_phone_verified');
  });

  it('omits tutorial_completed when tutorialCompletedAt set', () => {
    const missing = UsersService.computeMissingFields(
      { ...emptyUser, tutorialCompletedAt: new Date() },
      [],
      0,
    );
    expect(missing).not.toContain('tutorial_completed');
  });

  it('returns empty array for a fully complete profile', () => {
    expect(
      UsersService.computeMissingFields(
        {
          dateOfBirth: new Date('1990-01-01'),
          name: 'Alice',
          username: 'alice',
          avatarUrl: 'https://x/y.png',
          tutorialCompletedAt: new Date(),
        },
        [
          { type: CredentialType.PHONE },
          { type: CredentialType.EMAIL },
        ],
        5,
      ),
    ).toEqual([]);
  });
});
