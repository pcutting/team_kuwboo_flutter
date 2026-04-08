import { Entity, PrimaryKey, Property, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';

@Entity({ tableName: 'tags' })
export class Tag {
  [OptionalProps]?: 'usageCount' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Property({ type: 'varchar', length: 50, unique: true })
  name!: string;

  @Property({ type: 'int', default: 0 })
  usageCount: number = 0;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
