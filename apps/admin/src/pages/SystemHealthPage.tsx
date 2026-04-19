import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { getSystemHealth } from '../api/client';

interface MemoryUsage {
  rss: number;
  heapUsed: number;
  heapTotal: number;
  external?: number;
  arrayBuffers?: number;
}

interface QueueStats {
  waiting: number;
  active: number;
  completed: number;
  failed: number;
  delayed?: number;
  paused?: number;
  prioritized?: number;
  'waiting-children'?: number;
}

interface HealthData {
  uptime: number;
  memoryUsage: MemoryUsage;
  nodeVersion: string;
  queueStats?: QueueStats;
}

function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const parts: string[] = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours > 0) parts.push(`${hours}h`);
  parts.push(`${minutes}m`);
  return parts.join(' ');
}

function formatBytes(bytes: number): string {
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}

export function SystemHealthPage() {
  const { accessToken } = useAuth();
  const [health, setHealth] = useState<HealthData | null>(null);
  const [error, setError] = useState('');
  const [lastFetched, setLastFetched] = useState<Date | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchHealth = useCallback(() => {
    if (!accessToken) return;
    setLoading(true);
    getSystemHealth(accessToken)
      .then((res) => {
        setHealth(res.data as unknown as HealthData);
        setLastFetched(new Date());
        setError('');
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [accessToken]);

  useEffect(() => {
    fetchHealth();
  }, [fetchHealth]);

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">System Health</h1>
          <p className="mt-1 text-sm text-stone-500">Server status and resource usage</p>
        </div>
        <div className="flex items-center gap-3">
          {lastFetched && (
            <span className="text-xs text-stone-400">
              Updated {lastFetched.toLocaleTimeString()}
            </span>
          )}
          <button
            onClick={fetchHealth}
            disabled={loading}
            className="px-3 py-1.5 text-xs font-medium text-amber-700 bg-amber-50 border border-amber-200 rounded-lg hover:bg-amber-100 disabled:opacity-50 transition-colors"
          >
            {loading ? 'Refreshing...' : 'Refresh'}
          </button>
        </div>
      </div>

      {error && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {health && (
        <>
          {/* Server Info */}
          <div className="mt-8">
            <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
              Server
            </h2>
            <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div className="bg-white rounded-xl border border-stone-200 p-5">
                <p className="text-sm text-stone-500">Uptime</p>
                <p className="mt-1 text-3xl font-bold text-green-700">
                  {formatUptime(health.uptime)}
                </p>
              </div>
              <div className="bg-white rounded-xl border border-stone-200 p-5">
                <p className="text-sm text-stone-500">Node.js Version</p>
                <p className="mt-1 text-3xl font-bold text-stone-900">
                  {health.nodeVersion}
                </p>
              </div>
            </div>
          </div>

          {/* Memory */}
          <div className="mt-10">
            <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
              Memory
            </h2>
            <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div className="bg-white rounded-xl border border-stone-200 p-5">
                <p className="text-sm text-stone-500">RSS</p>
                <p className="mt-1 text-3xl font-bold text-blue-700">
                  {formatBytes(health.memoryUsage.rss)}
                </p>
              </div>
              <div className="bg-white rounded-xl border border-stone-200 p-5">
                <p className="text-sm text-stone-500">Heap Used</p>
                <p className="mt-1 text-3xl font-bold text-amber-700">
                  {formatBytes(health.memoryUsage.heapUsed)}
                </p>
                <div className="mt-2 w-full bg-stone-100 rounded-full h-2">
                  <div
                    className="bg-amber-500 h-2 rounded-full transition-all"
                    style={{
                      width: `${Math.min(100, Math.round((health.memoryUsage.heapUsed / health.memoryUsage.heapTotal) * 100))}%`,
                    }}
                  />
                </div>
                <p className="mt-1 text-xs text-stone-400">
                  {Math.round((health.memoryUsage.heapUsed / health.memoryUsage.heapTotal) * 100)}% of heap
                </p>
              </div>
              <div className="bg-white rounded-xl border border-stone-200 p-5">
                <p className="text-sm text-stone-500">Heap Total</p>
                <p className="mt-1 text-3xl font-bold text-stone-700">
                  {formatBytes(health.memoryUsage.heapTotal)}
                </p>
              </div>
            </div>
          </div>

          {/* Queue Stats */}
          {health.queueStats && (
            <div className="mt-10">
              <h2 className="text-sm font-semibold text-stone-500 uppercase tracking-wider">
                Queue
              </h2>
              <div className="mt-3 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="bg-white rounded-xl border border-stone-200 p-5">
                  <p className="text-sm text-stone-500">Waiting</p>
                  <p className="mt-1 text-3xl font-bold text-yellow-700">
                    {health.queueStats.waiting.toLocaleString()}
                  </p>
                </div>
                <div className="bg-white rounded-xl border border-stone-200 p-5">
                  <p className="text-sm text-stone-500">Active</p>
                  <p className="mt-1 text-3xl font-bold text-blue-700">
                    {health.queueStats.active.toLocaleString()}
                  </p>
                </div>
                <div className="bg-white rounded-xl border border-stone-200 p-5">
                  <p className="text-sm text-stone-500">Completed</p>
                  <p className="mt-1 text-3xl font-bold text-green-700">
                    {health.queueStats.completed.toLocaleString()}
                  </p>
                </div>
                <div className="bg-white rounded-xl border border-stone-200 p-5">
                  <p className="text-sm text-stone-500">Failed</p>
                  <p className="mt-1 text-3xl font-bold text-red-700">
                    {health.queueStats.failed.toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          )}
        </>
      )}

      {!health && !error && (
        <div className="mt-8 flex items-center justify-center py-20">
          <p className="text-sm text-stone-400">Loading system health data...</p>
        </div>
      )}
    </div>
  );
}
