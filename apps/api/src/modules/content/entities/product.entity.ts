import { Entity, Property, Enum, OptionalProps } from '@mikro-orm/core';
import { Content } from './content.entity';
import { ProductCondition } from '../../../common/enums';

@Entity({ discriminatorValue: 'PRODUCT' })
export class Product extends Content {

  @Property({ type: 'varchar', length: 255 })
  title!: string;

  @Property({ type: 'text' })
  description!: string;

  @Property({ type: 'int' })
  priceCents!: number;

  @Property({ type: 'varchar', length: 3, default: 'GBP' })
  currency: string = 'GBP';

  @Enum({ items: () => ProductCondition })
  condition!: ProductCondition;

  @Property({ type: 'boolean', default: false })
  isDeal: boolean = false;

  @Property({ type: 'int', nullable: true })
  originalPriceCents?: number;
}
