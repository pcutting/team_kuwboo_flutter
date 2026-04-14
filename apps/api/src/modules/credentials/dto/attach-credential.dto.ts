import { IsEnum, IsOptional, IsString, Length } from 'class-validator';
import { CredentialType } from '../../../common/enums';

export class AttachCredentialDto {
  @IsEnum(CredentialType)
  type!: CredentialType;

  @IsString()
  @Length(1, 320)
  identifier!: string;

  /**
   * Required for `phone` and `email` credentials — the OTP the user just
   * received. Omitted for `google` / `apple` (those use their provider's
   * own idToken flow via the /auth/google or /auth/apple endpoints).
   */
  @IsOptional()
  @IsString()
  @Length(4, 12)
  otp?: string;
}
