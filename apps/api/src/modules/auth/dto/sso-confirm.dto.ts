import { IsString, IsUUID, Length } from 'class-validator';

export class GoogleConfirmDto {
  @IsString()
  idToken!: string;

  @IsString()
  @Length(4, 12)
  emailOtp!: string;

  @IsUUID()
  challengeId!: string;
}

export class AppleConfirmDto {
  @IsString()
  identityToken!: string;

  @IsString()
  @Length(4, 12)
  emailOtp!: string;

  @IsUUID()
  challengeId!: string;
}
