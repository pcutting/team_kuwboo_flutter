import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { listReports, enforceReport } from '../api/client';

type ReportFilter = 'all' | 'PENDING' | 'RESOLVED' | 'DISMISSED';

interface ReportRecord {
  id: string;
  targetType: string;
  targetId: string;
  reason: string;
  description?: string;
  reporterName: string;
  reporterId: string;
  targetUserName?: string;
  status: string;
  createdAt: string;
}

export function ReportsPage() {
  const { accessToken } = useAuth();
  const [reports, setReports] = useState<ReportRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<ReportFilter>('all');
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  const fetchReports = useCallback(() => {
    if (!accessToken) return;

    const params: Record<string, string> = { page: String(page), limit: '20' };
    if (filter !== 'all') params.status = filter;

    listReports(accessToken, params)
      .then((res) => {
        setReports(res.data.items as unknown as ReportRecord[]);
        setTotal(res.data.total);
      })
      .catch((err) => setError(err.message));
  }, [accessToken, page, filter]);

  useEffect(() => {
    fetchReports();
  }, [fetchReports]);

  const totalPages = Math.ceil(total / 20);

  function handleEnforce(
    reportId: string,
    action: string,
    reason?: string,
    durationDays?: number,
  ) {
    if (!accessToken) return;
    setActionLoading(reportId);
    setError('');

    enforceReport(accessToken, reportId, { action, reason, durationDays })
      .then(() => {
        setExpandedId(null);
        fetchReports();
      })
      .catch((err) => setError(err.message))
      .finally(() => setActionLoading(null));
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Reports</h1>
          <p className="mt-1 text-sm text-stone-500">
            {total} report{total !== 1 ? 's' : ''}
          </p>
        </div>
        <div className="flex gap-1 bg-stone-100 p-1 rounded-lg">
          {(
            [
              { value: 'all', label: 'All' },
              { value: 'PENDING', label: 'Pending' },
              { value: 'RESOLVED', label: 'Resolved' },
              { value: 'DISMISSED', label: 'Dismissed' },
            ] as const
          ).map((f) => (
            <button
              key={f.value}
              onClick={() => {
                setFilter(f.value);
                setPage(1);
              }}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors ${
                filter === f.value
                  ? 'bg-white text-stone-900 shadow-sm'
                  : 'text-stone-500 hover:text-stone-700'
              }`}
            >
              {f.label}
            </button>
          ))}
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
                Target
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Reason
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Reporter
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Date
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                &nbsp;
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-50">
            {reports.map((report) => (
              <ReportRow
                key={report.id}
                report={report}
                isExpanded={expandedId === report.id}
                onToggle={() =>
                  setExpandedId(
                    expandedId === report.id ? null : report.id,
                  )
                }
                onEnforce={(action, reason, duration) =>
                  handleEnforce(report.id, action, reason, duration)
                }
                isLoading={actionLoading === report.id}
              />
            ))}
            {reports.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  No reports found
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

function ReportRow({
  report,
  isExpanded,
  onToggle,
  onEnforce,
  isLoading,
}: {
  report: ReportRecord;
  isExpanded: boolean;
  onToggle: () => void;
  onEnforce: (action: string, reason?: string, duration?: number) => void;
  isLoading: boolean;
}) {
  return (
    <>
      <tr
        className="hover:bg-stone-50/50 cursor-pointer"
        onClick={onToggle}
      >
        <td className="px-4 py-3">
          <TargetTypeBadge type={report.targetType} />
        </td>
        <td className="px-4 py-3 text-sm text-stone-900">{report.reason}</td>
        <td className="px-4 py-3 text-sm text-stone-500">
          {report.reporterName}
        </td>
        <td className="px-4 py-3">
          <ReportStatusBadge status={report.status} />
        </td>
        <td className="px-4 py-3 text-sm text-stone-500">
          {new Date(report.createdAt).toLocaleDateString()}
        </td>
        <td className="px-4 py-3 text-sm text-stone-400">
          <svg
            className={`w-4 h-4 transition-transform ${isExpanded ? 'rotate-180' : ''}`}
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <path d="M6 9l6 6 6-6" />
          </svg>
        </td>
      </tr>
      {isExpanded && (
        <tr>
          <td colSpan={6} className="px-4 py-4 bg-stone-50/50">
            <div className="space-y-3">
              {report.description && (
                <div>
                  <p className="text-xs font-semibold text-stone-500 uppercase">
                    Description
                  </p>
                  <p className="mt-1 text-sm text-stone-700">
                    {report.description}
                  </p>
                </div>
              )}
              <div className="flex gap-2 items-center">
                <p className="text-xs font-semibold text-stone-500 uppercase mr-2">
                  Target ID
                </p>
                <span className="text-xs text-stone-500 font-mono bg-stone-100 px-2 py-0.5 rounded">
                  {report.targetId}
                </span>
              </div>
              {report.status === 'PENDING' && (
                <div className="flex gap-2 pt-2 border-t border-stone-200">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onEnforce('REMOVE_CONTENT');
                    }}
                    disabled={isLoading}
                    className="px-3 py-1.5 text-xs font-medium text-red-700 bg-red-50 rounded-lg hover:bg-red-100 disabled:opacity-50 transition-colors"
                  >
                    Remove Content
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onEnforce('WARN_USER');
                    }}
                    disabled={isLoading}
                    className="px-3 py-1.5 text-xs font-medium text-yellow-700 bg-yellow-50 rounded-lg hover:bg-yellow-100 disabled:opacity-50 transition-colors"
                  >
                    Warn User
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onEnforce('SUSPEND_USER');
                    }}
                    disabled={isLoading}
                    className="px-3 py-1.5 text-xs font-medium text-orange-700 bg-orange-50 rounded-lg hover:bg-orange-100 disabled:opacity-50 transition-colors"
                  >
                    Suspend User
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onEnforce('DISMISS');
                    }}
                    disabled={isLoading}
                    className="px-3 py-1.5 text-xs font-medium text-stone-600 bg-stone-100 rounded-lg hover:bg-stone-200 disabled:opacity-50 transition-colors"
                  >
                    Dismiss
                  </button>
                  {isLoading && (
                    <span className="text-xs text-stone-400 self-center">
                      Processing...
                    </span>
                  )}
                </div>
              )}
            </div>
          </td>
        </tr>
      )}
    </>
  );
}

function TargetTypeBadge({ type }: { type: string }) {
  const styles: Record<string, string> = {
    CONTENT: 'bg-blue-50 text-blue-700',
    USER: 'bg-purple-50 text-purple-700',
    COMMENT: 'bg-stone-100 text-stone-600',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[type] || 'bg-stone-100 text-stone-600'}`}
    >
      {type}
    </span>
  );
}

function ReportStatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    PENDING: 'bg-yellow-50 text-yellow-700',
    RESOLVED: 'bg-green-50 text-green-700',
    DISMISSED: 'bg-stone-100 text-stone-500',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[status] || 'bg-stone-100 text-stone-600'}`}
    >
      {status}
    </span>
  );
}
