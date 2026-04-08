import { Injectable, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Report } from './entities/report.entity';
import { ReportTargetType, ReportReason, ReportStatus } from '../../common/enums';

@Injectable()
export class ReportsService {
  constructor(private readonly em: EntityManager) {}

  async create(
    reporterId: string,
    targetType: ReportTargetType,
    targetId: string,
    reason: ReportReason,
    description?: string,
  ): Promise<Report> {
    const data: any = {
      reporter: this.em.getReference('User', reporterId),
      targetType,
      reason,
      description,
    };

    switch (targetType) {
      case ReportTargetType.CONTENT:
        data.reportedContent = this.em.getReference('Content', targetId);
        break;
      case ReportTargetType.USER:
        data.reportedUser = this.em.getReference('User', targetId);
        break;
      case ReportTargetType.COMMENT:
        data.reportedComment = this.em.getReference('Comment', targetId);
        break;
    }

    const report = this.em.create(Report, data);
    await this.em.flush();
    return report;
  }

  async getPending(page = 1, limit = 20): Promise<{ items: Report[]; total: number }> {
    const [items, total] = await this.em.findAndCount(
      Report,
      { status: { $in: [ReportStatus.PENDING, ReportStatus.IN_REVIEW] } },
      { orderBy: { createdAt: 'ASC' }, limit, offset: (page - 1) * limit, populate: ['reporter'] },
    );
    return { items, total };
  }

  async review(
    reportId: string,
    reviewerId: string,
    status: ReportStatus.DISMISSED | ReportStatus.RESOLVED,
    notes?: string,
  ): Promise<Report> {
    const report = await this.em.findOne(Report, { id: reportId });
    if (!report) throw new NotFoundException('Report not found');

    report.status = status;
    report.reviewedBy = reviewerId;
    report.reviewNotes = notes;
    report.reviewedAt = new Date();

    await this.em.flush();
    return report;
  }
}
