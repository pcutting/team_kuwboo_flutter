import { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { getSessionStats } from '../api/client';

interface SessionStatsData {
  totalActive: number;
  byPlatform?: Array<{ platform: string; count: number }>;
}

export function SessionsPage() {
  const { accessToken } = useAuth();
  const [stats, setStats] = useState<SessionStatsData | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!accessToken) return;

    getSessionStats(accessToken)
      .then((res) => setStats(res.data as unknown as SessionStatsData))
      .catch((err) => setError(err.message));
  }, [accessToken]);

  return (
    <div>
      <h1 className="text-2xl font-bold text-stone-900">Sessions</h1>
      <p className="mt-1 text-sm text-stone-500">Active user sessions</p>

      {error && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {/* Active Sessions */}
      <div className="mt-8">
        <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
          Overview
        </h2>
        <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white rounded-xl border border-stone-200 p-5">
            <p className="text-sm text-stone-500">Total Active Sessions</p>
            <p className="mt-1 text-3xl font-bold text-green-700">
              {stats?.totalActive !== undefined ? stats.totalActive.toLocaleString() : '\u2014'}
            </p>
          </div>
        </div>
      </div>

      {/* By Platform */}
      {stats?.byPlatform && stats.byPlatform.length > 0 && (
        <div className="mt-10">
          <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
            By Platform
          </h2>
          <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {stats.byPlatform.map((item) => (
              <div
                key={item.platform}
                className="bg-white rounded-xl border border-stone-200 p-5"
              >
                <p className="text-sm text-stone-500">{item.platform}</p>
                <p className="mt-1 text-3xl font-bold text-stone-900">
                  {item.count.toLocaleString()}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}

      {!stats && !error && (
        <div className="mt-8 flex items-center justify-center py-20">
          <p className="text-sm text-stone-400">Loading session data...</p>
        </div>
      )}
    </div>
  );
}
