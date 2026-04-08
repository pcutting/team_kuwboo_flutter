import { useEffect, useState, useCallback } from 'react';
import { useParams, Link } from 'react-router';
import { useAuth } from '../contexts/AuthContext';
import {
  getBotDetail,
  getBotActivityStats,
  getBotActivity,
  startBot,
  pauseBot,
  stopBot,
  resetBot,
} from '../api/client';

interface BotDetail {
  id: string;
  displayPersona: string;
  simulationStatus: string;
  totalActions: number;
  roamRadiusKm: number;
  lastSimulatedAt?: string;
  createdAt: string;
  user: {
    id: string;
    name: string;
    avatarUrl?: string;
    onlineStatus: string;
  };
  behaviorConfig?: {
    actionWeights?: Record<string, number>;
    activeHoursStart?: number;
    activeHoursEnd?: number;
    movementStyle?: string;
    roamRadiusKm?: number;
  };
}

interface ActivityStats {
  totalActions: number;
  successRate: number;
  actionsLast24h: number;
  actionsByType?: Array<{ type: string; count: number }>;
}

interface ActivityRecord {
  id: string;
  actionType: string;
  targetType?: string;
  targetId?: string;
  success: boolean;
  createdAt: string;
  error?: string;
}

export function BotDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [bot, setBot] = useState<BotDetail | null>(null);
  const [stats, setStats] = useState<ActivityStats | null>(null);
  const [activity, setActivity] = useState<ActivityRecord[]>([]);
  const [activityTotal, setActivityTotal] = useState(0);
  const [activityPage, setActivityPage] = useState(1);
  const [error, setError] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  const fetchBot = useCallback(() => {
    if (!accessToken || !id) return;
    getBotDetail(accessToken, id)
      .then((res) => setBot(res.data as unknown as BotDetail))
      .catch((err) => setError(err.message));
  }, [accessToken, id]);

  const fetchStats = useCallback(() => {
    if (!accessToken || !id) return;
    getBotActivityStats(accessToken, id)
      .then((res) => setStats(res.data as unknown as ActivityStats))
      .catch(() => {});
  }, [accessToken, id]);

  useEffect(() => {
    fetchBot();
    fetchStats();
  }, [fetchBot, fetchStats]);

  useEffect(() => {
    if (!accessToken || !id) return;
    getBotActivity(accessToken, id, {
      page: String(activityPage),
      limit: '15',
    })
      .then((res) => {
        setActivity(res.data.items as unknown as ActivityRecord[]);
        setActivityTotal(res.data.total);
      })
      .catch(() => {});
  }, [accessToken, id, activityPage]);

  async function handleAction(action: 'start' | 'pause' | 'stop' | 'reset') {
    if (!accessToken || !id) return;
    setActionLoading(true);
    setError('');
    try {
      const fns = { start: startBot, pause: pauseBot, stop: stopBot, reset: resetBot };
      await fns[action](accessToken, id);
      fetchBot();
      fetchStats();
    } catch (err) {
      setError(err instanceof Error ? err.message : `Failed to ${action} bot`);
    } finally {
      setActionLoading(false);
    }
  }

  const activityTotalPages = Math.ceil(activityTotal / 15);

  if (!bot && !error) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-sm text-stone-400">Loading bot details...</p>
      </div>
    );
  }

  const status = bot?.simulationStatus || '';

  return (
    <div>
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm text-stone-500 mb-6">
        <Link to="/dashboard/bots" className="hover:text-stone-700 transition-colors">
          Bots
        </Link>
        <span>/</span>
        <span className="text-stone-900">{bot?.user.name || 'Bot'}</span>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {bot && (
        <>
          {/* Header */}
          <div className="bg-white rounded-xl border border-stone-200 p-6">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 bg-purple-100 rounded-full flex items-center justify-center text-xl font-bold text-purple-600">
                  {bot.user.name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-2xl font-bold text-stone-900">{bot.user.name}</h1>
                    <SimStatusBadge status={status} />
                  </div>
                  <div className="mt-1 flex items-center gap-3 text-sm text-stone-500">
                    <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-purple-50 text-purple-600">
                      {bot.displayPersona.replace(/_/g, ' ')}
                    </span>
                    <span>{bot.roamRadiusKm}km radius</span>
                    <span>Created {new Date(bot.createdAt).toLocaleDateString()}</span>
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                {(status === 'IDLE' || status === 'PAUSED' || status === 'ERROR') && (
                  <button
                    onClick={() => handleAction('start')}
                    disabled={actionLoading}
                    className="px-3 py-1.5 text-xs font-medium text-green-700 bg-green-50 border border-green-200 rounded-lg hover:bg-green-100 disabled:opacity-50 transition-colors"
                  >
                    Start
                  </button>
                )}
                {status === 'RUNNING' && (
                  <button
                    onClick={() => handleAction('pause')}
                    disabled={actionLoading}
                    className="px-3 py-1.5 text-xs font-medium text-yellow-700 bg-yellow-50 border border-yellow-200 rounded-lg hover:bg-yellow-100 disabled:opacity-50 transition-colors"
                  >
                    Pause
                  </button>
                )}
                {(status === 'RUNNING' || status === 'PAUSED') && (
                  <button
                    onClick={() => handleAction('stop')}
                    disabled={actionLoading}
                    className="px-3 py-1.5 text-xs font-medium text-red-700 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 disabled:opacity-50 transition-colors"
                  >
                    Stop
                  </button>
                )}
                <button
                  onClick={() => handleAction('reset')}
                  disabled={actionLoading}
                  className="px-3 py-1.5 text-xs font-medium text-stone-700 bg-stone-50 border border-stone-200 rounded-lg hover:bg-stone-100 disabled:opacity-50 transition-colors"
                >
                  Reset
                </button>
              </div>
            </div>
          </div>

          {/* Stats Cards */}
          <div className="mt-6 grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <StatCard
              label="Total Actions"
              value={stats?.totalActions ?? bot.totalActions}
              accent="text-blue-700"
            />
            <StatCard
              label="Success Rate"
              value={stats?.successRate !== undefined ? `${Math.round(stats.successRate * 100)}%` : undefined}
              accent="text-green-700"
            />
            <StatCard
              label="Actions (24h)"
              value={stats?.actionsLast24h}
              accent="text-amber-700"
            />
          </div>

          {/* Actions by Type + Behavior Config */}
          <div className="mt-6 grid sm:grid-cols-2 gap-6">
            {/* Actions by Type */}
            <div className="bg-white rounded-xl border border-stone-200 p-5">
              <h3 className="text-sm font-semibold text-stone-500 uppercase tracking-wider mb-3">
                Actions by Type
              </h3>
              <div className="space-y-2">
                {stats?.actionsByType && stats.actionsByType.length > 0 ? (
                  stats.actionsByType.map((item) => (
                    <div key={item.type} className="flex items-center justify-between">
                      <span className="text-sm text-stone-600">
                        {item.type.replace(/_/g, ' ')}
                      </span>
                      <span className="text-sm font-semibold text-stone-900">
                        {item.count.toLocaleString()}
                      </span>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-stone-400">No action data</p>
                )}
              </div>
            </div>

            {/* Behavior Config */}
            <div className="bg-white rounded-xl border border-stone-200 p-5">
              <h3 className="text-sm font-semibold text-stone-500 uppercase tracking-wider mb-3">
                Behavior Config
              </h3>
              {bot.behaviorConfig ? (
                <div className="space-y-3">
                  {bot.behaviorConfig.activeHoursStart !== undefined && (
                    <ConfigRow
                      label="Active Hours"
                      value={`${bot.behaviorConfig.activeHoursStart}:00 - ${bot.behaviorConfig.activeHoursEnd}:00`}
                    />
                  )}
                  {bot.behaviorConfig.movementStyle && (
                    <ConfigRow
                      label="Movement Style"
                      value={bot.behaviorConfig.movementStyle.replace(/_/g, ' ')}
                    />
                  )}
                  {bot.behaviorConfig.roamRadiusKm !== undefined && (
                    <ConfigRow
                      label="Roam Radius"
                      value={`${bot.behaviorConfig.roamRadiusKm} km`}
                    />
                  )}
                  {bot.behaviorConfig.actionWeights && (
                    <div>
                      <p className="text-xs text-stone-400 mb-1">Action Weights</p>
                      <div className="space-y-1">
                        {Object.entries(bot.behaviorConfig.actionWeights).map(([key, val]) => (
                          <div key={key} className="flex items-center justify-between">
                            <span className="text-sm text-stone-600">
                              {key.replace(/_/g, ' ')}
                            </span>
                            <span className="text-sm font-medium text-stone-900">{val}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <p className="text-sm text-stone-400">No config data available</p>
              )}
            </div>
          </div>

          {/* Activity Log */}
          <div className="mt-8">
            <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider mb-3">
              Activity Log
            </h2>
            <div className="bg-white rounded-xl border border-stone-200 overflow-hidden">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-stone-100">
                    <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                      Target
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                      Time
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-stone-50">
                  {activity.map((item) => (
                    <tr key={item.id} className="hover:bg-stone-50/50">
                      <td className="px-4 py-3">
                        <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-stone-100 text-stone-600">
                          {item.actionType.replace(/_/g, ' ')}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-stone-500">
                        {item.targetType
                          ? `${item.targetType} ${item.targetId ? `#${item.targetId.slice(0, 8)}` : ''}`
                          : '\u2014'}
                      </td>
                      <td className="px-4 py-3">
                        <span
                          className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                            item.success
                              ? 'bg-green-50 text-green-700'
                              : 'bg-red-50 text-red-700'
                          }`}
                        >
                          {item.success ? 'Success' : 'Failed'}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-stone-500">
                        {new Date(item.createdAt).toLocaleString()}
                      </td>
                    </tr>
                  ))}
                  {activity.length === 0 && (
                    <tr>
                      <td colSpan={4} className="px-4 py-12 text-center text-sm text-stone-400">
                        No activity recorded
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
              {activityTotalPages > 1 && (
                <div className="px-4 py-3 border-t border-stone-100 flex items-center justify-between">
                  <p className="text-sm text-stone-500">
                    Page {activityPage} of {activityTotalPages}
                  </p>
                  <div className="flex gap-2">
                    <button
                      onClick={() => setActivityPage((p) => Math.max(1, p - 1))}
                      disabled={activityPage <= 1}
                      className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Previous
                    </button>
                    <button
                      onClick={() => setActivityPage((p) => Math.min(activityTotalPages, p + 1))}
                      disabled={activityPage >= activityTotalPages}
                      className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Next
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function StatCard({
  label,
  value,
  accent,
}: {
  label: string;
  value?: number | string;
  accent: string;
}) {
  return (
    <div className="bg-white rounded-xl border border-stone-200 p-5">
      <p className="text-sm text-stone-500">{label}</p>
      <p className={`mt-1 text-3xl font-bold ${accent}`}>
        {value !== undefined
          ? typeof value === 'number'
            ? value.toLocaleString()
            : value
          : '\u2014'}
      </p>
    </div>
  );
}

function ConfigRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-sm text-stone-500">{label}</span>
      <span className="text-sm font-medium text-stone-900">{value}</span>
    </div>
  );
}

function SimStatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    RUNNING: 'bg-green-50 text-green-700',
    PAUSED: 'bg-yellow-50 text-yellow-700',
    IDLE: 'bg-stone-100 text-stone-500',
    ERROR: 'bg-red-50 text-red-700',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[status] || 'bg-stone-100 text-stone-600'}`}
    >
      {status}
    </span>
  );
}
