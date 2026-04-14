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
