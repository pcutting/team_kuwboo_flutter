import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { listCampaigns, updateCampaignStatus } from '../api/client';

type CampaignFilter = 'all' | 'PENDING' | 'ACTIVE' | 'PAUSED' | 'COMPLETED';

interface CampaignRecord {
  id: string;
  name: string;
  advertiserName: string;
  status: string;
  budget: number;
  startDate: string;
  endDate: string;
}

export function SponsoredPage() {
  const { accessToken } = useAuth();
  const [items, setItems] = useState<CampaignRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<CampaignFilter>('all');
  const [error, setError] = useState('');
  const [confirmAction, setConfirmAction] = useState<{
    id: string;
    action: string;
    label: string;
  } | null>(null);
  const [actionLoading, setActionLoading] = useState(false);

  const fetchCampaigns = useCallback(() => {
    if (!accessToken) return;

    const params: Record<string, string> = { page: String(page), limit: '20' };
    if (filter !== 'all') params.status = filter;

    listCampaigns(accessToken, params)
      .then((res) => {
        setItems(res.data.items as unknown as CampaignRecord[]);
        setTotal(res.data.total);
      })
      .catch((err) => setError(err.message));
  }, [accessToken, page, filter]);

  useEffect(() => {
    fetchCampaigns();
  }, [fetchCampaigns]);

  const totalPages = Math.ceil(total / 20);

  function handleAction(id: string, action: string, label: string) {
    setConfirmAction({ id, action, label });
  }

  function executeAction(id: string, action: string) {
    if (!accessToken) return;
    setActionLoading(true);
    setError('');

    updateCampaignStatus(accessToken, id, action)
      .then(() => {
        setConfirmAction(null);
        fetchCampaigns();
      })
      .catch((err) => setError(err.message))
      .finally(() => setActionLoading(false));
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Sponsored</h1>
          <p className="mt-1 text-sm text-stone-500">
            {total} campaign{total !== 1 ? 's' : ''}
          </p>
        </div>
        <div className="flex gap-1 bg-stone-100 p-1 rounded-lg">
          {(
            [
              { value: 'all', label: 'All' },
              { value: 'PENDING', label: 'Pending' },
              { value: 'ACTIVE', label: 'Active' },
              { value: 'PAUSED', label: 'Paused' },
              { value: 'COMPLETED', label: 'Completed' },
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
                Campaign
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Advertiser
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Budget
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Start
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                End
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-50">
            {items.map((item) => (
              <tr key={item.id} className="hover:bg-stone-50/50">
                <td className="px-4 py-3 text-sm font-medium text-stone-900">
                  {item.name}
                </td>
                <td className="px-4 py-3 text-sm text-stone-600">
                  {item.advertiserName}
                </td>
                <td className="px-4 py-3">
                  <CampaignStatusBadge status={item.status} />
                </td>
                <td className="px-4 py-3 text-sm text-stone-600">
                  ${item.budget?.toLocaleString() ?? '0'}
                </td>
                <td className="px-4 py-3 text-sm text-stone-500">
                  {new Date(item.startDate).toLocaleDateString()}
                </td>
                <td className="px-4 py-3 text-sm text-stone-500">
                  {new Date(item.endDate).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <div className="flex gap-1">
                    {item.status === 'PENDING' && (
                      <>
                        <button
                          onClick={() =>
                            handleAction(item.id, 'ACTIVE', 'Approve')
                          }
                          className="px-2 py-1 text-xs font-medium text-green-700 bg-green-50 rounded hover:bg-green-100 transition-colors"
                        >
                          Approve
                        </button>
                        <button
                          onClick={() =>
                            handleAction(item.id, 'REJECTED', 'Reject')
                          }
                          className="px-2 py-1 text-xs font-medium text-red-700 bg-red-50 rounded hover:bg-red-100 transition-colors"
                        >
                          Reject
                        </button>
                      </>
                    )}
                    {item.status === 'ACTIVE' && (
                      <button
                        onClick={() =>
                          handleAction(item.id, 'PAUSED', 'Pause')
                        }
                        className="px-2 py-1 text-xs font-medium text-yellow-700 bg-yellow-50 rounded hover:bg-yellow-100 transition-colors"
                      >
                        Pause
                      </button>
                    )}
                    {item.status === 'PAUSED' && (
                      <button
                        onClick={() =>
                          handleAction(item.id, 'ACTIVE', 'Resume')
                        }
                        className="px-2 py-1 text-xs font-medium text-green-700 bg-green-50 rounded hover:bg-green-100 transition-colors"
                      >
                        Resume
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td
                  colSpan={7}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  No campaigns found
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

      {/* Confirmation Dialog */}
      {confirmAction && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setConfirmAction(null)}
          />
          <div className="relative bg-white rounded-xl shadow-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-stone-900">
              {confirmAction.label} Campaign
            </h3>
            <p className="mt-2 text-sm text-stone-500">
              Are you sure you want to {confirmAction.label.toLowerCase()} this
              campaign?
            </p>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setConfirmAction(null)}
                className="px-4 py-2 text-sm font-medium text-stone-600 border border-stone-200 rounded-lg hover:bg-stone-50"
              >
                Cancel
              </button>
              <button
                onClick={() =>
                  executeAction(confirmAction.id, confirmAction.action)
                }
                disabled={actionLoading}
                className={`px-4 py-2 text-sm font-medium text-white rounded-lg disabled:opacity-50 ${
                  confirmAction.action === 'REJECTED'
                    ? 'bg-red-600 hover:bg-red-700'
                    : confirmAction.action === 'PAUSED'
                      ? 'bg-yellow-600 hover:bg-yellow-700'
                      : 'bg-green-600 hover:bg-green-700'
                }`}
              >
                {actionLoading ? 'Processing...' : confirmAction.label}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function CampaignStatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    ACTIVE: 'bg-green-50 text-green-700',
    PENDING: 'bg-amber-50 text-amber-700',
    PAUSED: 'bg-yellow-50 text-yellow-700',
    REJECTED: 'bg-red-50 text-red-700',
    COMPLETED: 'bg-stone-100 text-stone-600',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[status] || 'bg-stone-100 text-stone-600'}`}
    >
      {status}
    </span>
  );
}
