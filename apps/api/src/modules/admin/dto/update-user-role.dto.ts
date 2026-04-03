import { IsEnum } from 'class-validator';
import { Role } from '../../../common/enums';

export class UpdateUserRoleDto {
  @IsEnum(Role)
  role!: Role;
}
