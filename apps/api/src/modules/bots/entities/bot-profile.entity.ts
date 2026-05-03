import {
  Entity,
  PrimaryKey,
  Property,
  Enum,
  OneToOne,
  Index,
  OptionalProps,
} from '@mikro-orm/core';
import { randomUUID } from 'crypto';
import { User } from '../../users/entities/user.entity';
import { PointType, Point } from '../../../database/types/point.type';
import { BotSimulationStatus } from '../../../common/enums';

export interface BotVideoTemplate {
  videoUrl: string;
  thumbnailUrl: string;
  durationSeconds: number;
  caption?: string;
}

export interface BotBehaviorConfig {
  actionWeights: {
    createPost: number;
    createVideo: number;
    likeContent: number;
    commentOnContent: number;
    viewContent: number;
    followUser: number;
    sendWave: number;
    respondToWave: number;
    moveLocation: number;
    sendMessage: number;
  };
  minActionIntervalMs: number;
  maxActionIntervalMs: number;
  activeHoursStart: number;
  activeHoursEnd: number;
  postTemplates: string[];
  videoTemplates: BotVideoTemplate[];
  commentTemplates: string[];
  waveMessages: string[];
  movementStyle: 'random_walk' | 'commute' | 'wander' | 'stationary';
  movementSpeedKmH: number;
}

@Entity({ tableName: 'bot_profiles' })
@Index({ properties: ['simulationStatus'] })
export class BotProfile {
  [OptionalProps]?:
    | 'simulationStatus'
    | 'roamRadiusKm'
    | 'totalActions'
    | 'createdAt'
    | 'updatedAt';

  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @OneToOne(() => User, { owner: true, unique: true })
  user!: User;

  @Property({ type: 'varchar', length: 50 })
  displayPersona!: string;

  @Property({ type: 'text', nullable: true })
  backstory?: string;

  @Property({ type: 'jsonb' })
  behaviorConfig!: BotBehaviorConfig;

  @Enum({ items: () => BotSimulationStatus, default: BotSimulationStatus.IDLE })
  simulationStatus: BotSimulationStatus = BotSimulationStatus.IDLE;

  @Property({ type: PointType, nullable: true })
  homeLocation?: Point;

  @Property({ type: 'int', default: 5 })
  roamRadiusKm: number = 5;

  @Property({ type: 'timestamptz', nullable: true })
  lastSimulatedAt?: Date;

  @Property({ type: 'int', default: 0 })
  totalActions: number = 0;

  @Property({ type: 'varchar', length: 255, nullable: true })
  errorMessage?: string;

  @Property({ type: 'timestamptz', defaultRaw: 'now()' })
  createdAt: Date = new Date();

  @Property({ type: 'timestamptz', defaultRaw: 'now()', onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
