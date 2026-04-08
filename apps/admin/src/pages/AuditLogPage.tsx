import { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { getAuditLog } from '../api/client';

interface AuditRecord {
  id: string;
  adminName: string;
  actionType: string;
  targetType: string;
  targetId: string;
  details?: Record<string, unknown>;
  createdAt: string;
}

const ACTION_TYPES = [
  '',
  'USER_SUSPEND',
  'USER_WARN',
  'USER_BAN',
  'CONTENT_REMOVE',
  'CONTENT_HIDE',
  'CONTENT_RESTORE',
  'REPORT_ENFORCE',
  'REPORT_DISMISS',
  'SESSION_REVOKE',
];

export function AuditLogPage() {
  const { accessToken } = useAuth();
  const [items, setItems] = useState<AuditRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [actionFilter, setActionFilter] = useState('');
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!accessToken) return;

    const params: Record<string, string> = { page: String(page), limit: '20' };
    if (actionFilter) params.actionType = actionFilter;

    getAuditLog(accessToken, params)
      .then((res) => {
        setItems(res.data.items as unknown as AuditRecord[]);
        setTotal(res.data.total);
      })
      .catch((err) => setError(err.message));
  }, [accessToken, page, actionFilter]);

  const totalPages = Math.ceil(total / 20);

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Audit Log</h1>
          <p className="mt-1 text-sm text-stone-500">
            {total} entr{total !== 1 ? 'ies' : 'y'}
          </p>
        </div>
        <div>
          <select
            value={actionFilter}
            onChange={(e) => {
              setActionFilter(e.target.value);
              setPage(1);
            }}
            className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg bg-white text-stone-700 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
          >
            <option value="">All Actions</option>
            {ACTION_TYPES.filter(Boolean).map((type) => (
              <option key={type} value={type}>
                {type.replace(/_/g, ' ')}
              </option>
            ))}
          </select>
        </div>
      </div>

      {error && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      <div className="mt-6 bg-white rounded-xl border border-stone-200 overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-stone-100">
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Admin
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Action
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Target Type
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Target ID
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Timestamp
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                &nbsp;
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-50">
            {items.map((item) => (
              <AuditRow
                key={item.id}
                item={item}
                isExpanded={expandedId === item.id}
                onToggle={() =>
                  setExpandedId(expandedId === item.id ? null : item.id)
                }
              />
            ))}
            {items.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  No audit log entries found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="mt-4 flex items-center justify-between">
          <p className="text-sm text-stone-500">
            Page {page} of {totalPages}
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page <= 1}
              className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page >= totalPages}
              className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function AuditRow({
  item,
  isExpanded,
  onToggle,
}: {
  item: AuditRecord;
  isExpanded: boolean;
  onToggle: () => void;
}) {
  return (
    <>
      <tr
        className="hover:bg-stone-50/50 cursor-pointer"
        onClick={onToggle}
      >
        <td className="px-4 py-3 text-sm font-medium text-stone-900">
          {item.adminName}
        </td>
        <td className="px-4 py-3">
          <ActionBadge action={item.actionType} />
        </td>
        <td className="px-4 py-3 text-sm text-stone-500">{item.targetType}</td>
        <td className="px-4 py-3">
          <span className="text-xs text-stone-500 font-mono bg-stone-100 px-2 py-0.5 rounded">
            {item.targetId}
          </span>
        </td>
        <td className="px-4 py-3 text-sm text-stone-500">
          {new Date(item.createdAt).toLocaleString()}
        </td>
        <td className="px-4 py-3 text-sm text-stone-400">
          {item.details && (
            <svg
              className={`w-4 h-4 transition-transform ${isExpanded ? 'rotate-180' : ''}`}
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
            >
              <path d="M6 9l6 6 6-6" />
            </svg>
          )}
        </td>
      </tr>
      {isExpanded && item.details && (
        <tr>
          <td colSpan={6} className="px-4 py-4 bg-stone-50/50">
            <div>
              <p className="text-xs font-semibold text-stone-500 uppercase mb-2">
                Details
              </p>
              <pre className="text-xs text-stone-600 bg-stone-100 rounded-lg p-3 overflow-x-auto">
                {JSON.stringify(item.details, null, 2)}
              </pre>
            </div>
          </td>
        </tr>
      )}
    </>
  );
}

function ActionBadge({ action }: { action: string }) {
  const styles: Record<string, string> = {
    USER_SUSPEND: 'bg-yellow-50 text-yellow-700',
    USER_WARN: 'bg-orange-50 text-orange-700',
    USER_BAN: 'bg-red-50 text-red-700',
    CONTENT_REMOVE: 'bg-red-50 text-red-700',
    CONTENT_HIDE: 'bg-yellow-50 text-yellow-700',
    CONTENT_RESTORE: 'bg-green-50 text-green-700',
    REPORT_ENFORCE: 'bg-blue-50 text-blue-700',
    REPORT_DISMISS: 'bg-stone-100 text-stone-500',
    SESSION_REVOKE: 'bg-purple-50 text-purple-700',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[action] || 'bg-stone-100 text-stone-600'}`}
    >
      {action.replace(/_/g, ' ')}
    </span>
  );
}
