import { IsEmail, IsString, Length } from 'class-validator';

export class SendEmailOtpDto {
  @IsEmail()
  email!: string;
}

export class VerifyEmailOtpDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Length(4, 12)
  code!: string;
}
