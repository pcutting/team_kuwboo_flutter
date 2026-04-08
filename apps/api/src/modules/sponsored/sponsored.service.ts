import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { SponsoredCampaign } from './entities/sponsored-campaign.entity';
import { Content } from '../content/entities/content.entity';
import { User } from '../users/entities/user.entity';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { CampaignStatus } from '../../common/enums';

@Injectable()
export class SponsoredService {
  constructor(private readonly em: EntityManager) {}

  async createCampaign(user: User, dto: CreateCampaignDto): Promise<SponsoredCampaign> {
    const content = await this.em.findOne(Content, { id: dto.contentId, creator: user });
    if (!content) throw new NotFoundException('Content not found or not owned by user');

    const campaign = this.em.create(SponsoredCampaign, {
      advertiser: user,
      content,
      budgetCents: dto.budgetCents,
      targeting: dto.targeting,
      startsAt: new Date(dto.startsAt),
      endsAt: new Date(dto.endsAt),
    } as any);

    await this.em.flush();
    return campaign;
  }

  async getCampaigns(
    userId: string,
    cursor?: string,
    limit = 20,
  ): Promise<{ items: SponsoredCampaign[]; nextCursor?: string }> {
    const where: Record<string, any> = { advertiser: userId };
    if (cursor) where.createdAt = { $lt: new Date(cursor) };

    const items = await this.em.find(SponsoredCampaign, where, {
      orderBy: { createdAt: 'DESC' },
      limit: limit + 1,
      populate: ['content'],
    });

    const hasMore = items.length > limit;
    if (hasMore) items.pop();

    return {
      items,
      nextCursor: hasMore ? items[items.length - 1].createdAt.toISOString() : undefined,
    };
  }

  async updateCampaignStatus(
    userId: string,
    campaignId: string,
    status: CampaignStatus,
  ): Promise<SponsoredCampaign> {
    const campaign = await this.em.findOne(SponsoredCampaign, { id: campaignId }, { populate: ['advertiser'] });
    if (!campaign) throw new NotFoundException('Campaign not found');

    if (campaign.advertiser.id !== userId) {
      throw new ForbiddenException('Not the campaign owner');
    }

    // Validate allowed transitions
    const allowed: Record<string, CampaignStatus[]> = {
      [CampaignStatus.DRAFT]: [CampaignStatus.ACTIVE],
      [CampaignStatus.ACTIVE]: [CampaignStatus.PAUSED, CampaignStatus.ENDED],
      [CampaignStatus.PAUSED]: [CampaignStatus.ACTIVE, CampaignStatus.ENDED],
      [CampaignStatus.ENDED]: [],
    };

    if (!allowed[campaign.status]?.includes(status)) {
      throw new BadRequestException(
        `Cannot transition from ${campaign.status} to ${status}`,
      );
    }

    campaign.status = status;
    await this.em.flush();
    return campaign;
  }
}
