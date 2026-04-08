import { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
  getEngagementMetrics,
  getGrowthMetrics,
  getContentBreakdown,
  getActiveUsers,
} from '../api/client';

interface EngagementData {
  totalContent: number;
  totalPosts: number;
  totalVideos: number;
  totalComments: number;
  totalLikes: number;
  totalViews: number;
  totalWaves: number;
  totalConnections: number;
}

interface GrowthDay {
  date: string;
  count: number;
}

interface ContentBreakdownData {
  byType: Array<{ type: string; count: number }>;
  byStatus: Array<{ status: string; count: number }>;
}

export function AnalyticsPage() {
  const { accessToken } = useAuth();
  const [engagement, setEngagement] = useState<EngagementData | null>(null);
  const [growth, setGrowth] = useState<GrowthDay[]>([]);
  const [content, setContent] = useState<ContentBreakdownData | null>(null);
  const [activeUserCount, setActiveUserCount] = useState<number | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!accessToken) return;

    Promise.all([
      getEngagementMetrics(accessToken).catch(() => null),
      getGrowthMetrics(accessToken, 30).catch(() => null),
      getContentBreakdown(accessToken).catch(() => null),
      getActiveUsers(accessToken, 30).catch(() => null),
    ]).then(([engRes, growthRes, contentRes, activeRes]) => {
      if (engRes) setEngagement(engRes.data as unknown as EngagementData);
      if (growthRes) {
        const d = growthRes.data as unknown as { daily?: GrowthDay[] };
        if (d.daily) setGrowth(d.daily);
        else if (Array.isArray(growthRes.data)) setGrowth(growthRes.data as unknown as GrowthDay[]);
      }
      if (contentRes) setContent(contentRes.data as unknown as ContentBreakdownData);
      if (activeRes) {
        const a = activeRes.data as unknown as { count?: number; activeUsers?: number };
        setActiveUserCount(a.count ?? a.activeUsers ?? null);
      }
      if (!engRes && !growthRes && !contentRes && !activeRes) {
        setError('Failed to load analytics data');
      }
    });
  }, [accessToken]);

  return (
    <div>
      <h1 className="text-2xl font-bold text-stone-900">Analytics</h1>
      <p className="mt-1 text-sm text-stone-500">Platform engagement and growth</p>

      {error && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {/* Active Users */}
      {activeUserCount !== null && (
        <div className="mt-8">
          <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
            Active Users
          </h2>
          <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              label="Daily Active Users"
              value={activeUserCount}
              accent="text-green-700"
            />
          </div>
        </div>
      )}

      {/* Engagement */}
      <div className="mt-8">
        <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
          Engagement
        </h2>
        <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard label="Total Content" value={engagement?.totalContent} accent="text-blue-700" />
          <StatCard label="Posts" value={engagement?.totalPosts} accent="text-indigo-700" />
          <StatCard label="Videos" value={engagement?.totalVideos} accent="text-purple-700" />
          <StatCard label="Comments" value={engagement?.totalComments} accent="text-stone-700" />
          <StatCard label="Likes" value={engagement?.totalLikes} accent="text-pink-700" />
          <StatCard label="Views" value={engagement?.totalViews} accent="text-amber-700" />
          <StatCard label="Waves" value={engagement?.totalWaves} accent="text-cyan-700" />
          <StatCard label="Connections" value={engagement?.totalConnections} accent="text-green-700" />
        </div>
      </div>

      {/* Content Breakdown */}
      {content && (
        <div className="mt-10">
          <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
            Content Breakdown
          </h2>
          <div className="mt-3 grid sm:grid-cols-2 gap-6">
            {/* By Type */}
            <div className="bg-white rounded-xl border border-stone-200 p-5">
              <h3 className="text-sm font-medium text-stone-700 mb-3">By Type</h3>
              <div className="space-y-2">
                {content.byType && content.byType.length > 0 ? (
                  content.byType.map((item) => (
                    <div key={item.type} className="flex items-center justify-between">
                      <span className="text-sm text-stone-600">{item.type}</span>
                      <span className="text-sm font-semibold text-stone-900">
                        {item.count.toLocaleString()}
                      </span>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-stone-400">No data</p>
                )}
              </div>
            </div>

            {/* By Status */}
            <div className="bg-white rounded-xl border border-stone-200 p-5">
              <h3 className="text-sm font-medium text-stone-700 mb-3">By Status</h3>
              <div className="space-y-2">
                {content.byStatus && content.byStatus.length > 0 ? (
                  content.byStatus.map((item) => (
                    <div key={item.status} className="flex items-center justify-between">
                      <span className="text-sm text-stone-600">{item.status}</span>
                      <span className="text-sm font-semibold text-stone-900">
                        {item.count.toLocaleString()}
                      </span>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-stone-400">No data</p>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Growth - Daily Signups Table */}
      <div className="mt-10">
        <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
          Growth &mdash; Daily Signups (Last 30 Days)
        </h2>
        <div className="mt-3 bg-white rounded-xl border border-stone-200 overflow-hidden">
          {growth.length > 0 ? (
            <table className="w-full">
              <thead>
                <tr className="border-b border-stone-100">
                  <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                    New Users
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider w-1/2">
                    &nbsp;
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-50">
                {growth.map((day) => {
                  const maxCount = Math.max(...growth.map((d) => d.count), 1);
                  const pct = Math.round((day.count / maxCount) * 100);
                  return (
                    <tr key={day.date} className="hover:bg-stone-50/50">
                      <td className="px-4 py-2.5 text-sm text-stone-600">
                        {new Date(day.date).toLocaleDateString()}
                      </td>
                      <td className="px-4 py-2.5 text-sm font-medium text-stone-900">
                        {day.count.toLocaleString()}
                      </td>
                      <td className="px-4 py-2.5">
                        <div className="w-full bg-stone-100 rounded-full h-2">
                          <div
                            className="bg-amber-500 h-2 rounded-full transition-all"
                            style={{ width: `${pct}%` }}
                          />
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          ) : (
            <div className="p-12 text-center text-sm text-stone-400">
              No growth data available
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function StatCard({
  label,
  value,
  accent,
}: {
  label: string;
  value?: number;
  accent: string;
}) {
  return (
    <div className="bg-white rounded-xl border border-stone-200 p-5">
      <p className="text-sm text-stone-500">{label}</p>
      <p className={`mt-1 text-3xl font-bold ${accent}`}>
        {value !== undefined ? value.toLocaleString() : '\u2014'}
      </p>
    </div>
  );
}
