import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Interest } from './entities/interest.entity';
import { UserInterest } from './entities/user-interest.entity';
import { User } from '../users/entities/user.entity';
import { CreateInterestDto } from './dto/create-interest.dto';
import { UpdateInterestDto } from './dto/update-interest.dto';

@Injectable()
export class InterestsService {
  constructor(private readonly em: EntityManager) {}

  // --- Public ---

  listActive(): Promise<Interest[]> {
    return this.em.find(
      Interest,
      { isActive: true },
      { orderBy: { displayOrder: 'ASC', label: 'ASC' } },
    );
  }

  // --- User-scoped (declared) ---

  listMine(userId: string): Promise<UserInterest[]> {
    return this.em.find(
      UserInterest,
      { user: { id: userId } },
      { populate: ['interest'], orderBy: { selectedAt: 'ASC' } },
    );
  }

  /**
   * Replace the user's declared interest set with the provided ids.
   * All ids must resolve to active interests; unknown/inactive => 400.
   */
  async selectMany(userId: string, interestIds: string[]): Promise<UserInterest[]> {
    const unique = Array.from(new Set(interestIds));

    if (unique.length === 0) {
      await this.em.nativeDelete(UserInterest, { user: { id: userId } });
      return [];
    }

    const interests = await this.em.find(Interest, {
      id: { $in: unique },
      isActive: true,
    });

    if (interests.length !== unique.length) {
      throw new BadRequestException(
        'One or more interest_ids are unknown or inactive',
      );
    }

    // Replace strategy: delete existing, insert new.
    await this.em.nativeDelete(UserInterest, { user: { id: userId } });

    for (const interest of interests) {
      const link = this.em.create(UserInterest, {
        user: this.em.getReference(User, userId),
        interest,
      } as never);
      this.em.persist(link);
    }
    await this.em.flush();

    return this.listMine(userId);
  }

  async deselect(userId: string, interestId: string): Promise<void> {
    const removed = await this.em.nativeDelete(UserInterest, {
      user: { id: userId },
      interest: { id: interestId },
    });
    if (removed === 0) {
      throw new NotFoundException('Interest not in user set');
    }
  }

  // --- Admin ---

  adminList(): Promise<Interest[]> {
    return this.em.find(
      Interest,
      {},
      { orderBy: { displayOrder: 'ASC', label: 'ASC' } },
    );
  }

  async adminCreate(dto: CreateInterestDto): Promise<Interest> {
    const existing = await this.em.findOne(Interest, { slug: dto.slug });
    if (existing) {
      throw new ConflictException(`Interest with slug "${dto.slug}" already exists`);
    }
    const interest = this.em.create(Interest, {
      slug: dto.slug,
      label: dto.label,
      category: dto.category,
      displayOrder: dto.display_order ?? 0,
    } as never);
    await this.em.flush();
    return interest;
  }

  async adminUpdate(id: string, dto: UpdateInterestDto): Promise<Interest> {
    const interest = await this.em.findOne(Interest, { id });
    if (!interest) throw new NotFoundException('Interest not found');

    if (dto.label !== undefined) interest.label = dto.label;
    if (dto.category !== undefined) interest.category = dto.category;
    if (dto.display_order !== undefined) interest.displayOrder = dto.display_order;
    if (dto.is_active !== undefined) interest.isActive = dto.is_active;
    interest.updatedAt = new Date();

    await this.em.flush();
    return interest;
  }

  /**
   * Soft-delete: sets is_active=false. Never removes the row or any
   * user_interests referencing it (history preservation).
   */
  async adminSoftDelete(id: string): Promise<void> {
    const interest = await this.em.findOne(Interest, { id });
    if (!interest) throw new NotFoundException('Interest not found');
    interest.isActive = false;
    interest.updatedAt = new Date();
    await this.em.flush();
  }

  async adminReorder(orderedIds: string[]): Promise<Interest[]> {
    if (orderedIds.length === 0) return [];

    const interests = await this.em.find(Interest, { id: { $in: orderedIds } });
    if (interests.length !== orderedIds.length) {
      throw new BadRequestException('One or more ids do not exist');
    }

    const byId = new Map(interests.map((i) => [i.id, i]));
    orderedIds.forEach((id, idx) => {
      const i = byId.get(id);
      if (i) {
        i.displayOrder = idx;
        i.updatedAt = new Date();
      }
    });
    await this.em.flush();

    return this.adminList();
  }
}
