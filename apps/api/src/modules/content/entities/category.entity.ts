import { Entity, PrimaryKey, Property, ManyToOne, OneToMany, Collection, Enum, OptionalProps } from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { CategoryScope } from '../../../common/enums';

@Entity({ tableName: 'categories' })
export class Category {
  [OptionalProps]?: 'sortOrder' | 'isActive' | 'createdAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Property({ type: 'varchar', length: 100 })
  name!: string;

  @Property({ type: 'varchar', length: 100, unique: true })
  slug!: string;

  @Enum({ items: () => CategoryScope })
  scope!: CategoryScope;

  @Property({ type: 'varchar', length: 512, nullable: true })
  iconUrl?: string;

  @Property({ type: 'int', default: 0 })
  sortOrder: number = 0;

  @Property({ type: 'boolean', default: true })
  isActive: boolean = true;

  @ManyToOne(() => Category, { nullable: true })
  parent?: Category;

  @OneToMany(() => Category, (c) => c.parent)
  children = new Collection<Category>(this);

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();
}
