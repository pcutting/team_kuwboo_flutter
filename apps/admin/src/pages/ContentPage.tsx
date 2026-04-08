import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { listContent, listFlaggedContent, updateContentStatus, restoreContent } from '../api/client';

type ContentStatus = 'all' | 'ACTIVE' | 'FLAGGED' | 'HIDDEN' | 'REMOVED';

interface ContentRecord {
  id: string;
  type: string;
  creatorName: string;
  status: string;
  likeCount: number;
  commentCount: number;
  viewCount: number;
  createdAt: string;
}

export function ContentPage() {
  const { accessToken } = useAuth();
  const [items, setItems] = useState<ContentRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<ContentStatus>('all');
  const [error, setError] = useState('');
  const [confirmAction, setConfirmAction] = useState<{
    id: string;
    action: string;
  } | null>(null);
  const [actionLoading, setActionLoading] = useState(false);

  const fetchContent = useCallback(() => {
    if (!accessToken) return;

    const params: Record<string, string> = { page: String(page), limit: '20' };
    if (filter !== 'all' && filter !== 'FLAGGED') params.status = filter;

    const fetcher =
      filter === 'FLAGGED'
        ? listFlaggedContent(accessToken, params)
        : listContent(accessToken, params);

    fetcher
      .then((res) => {
        setItems(res.data.items as unknown as ContentRecord[]);
        setTotal(res.data.total);
      })
      .catch((err) => setError(err.message));
  }, [accessToken, page, filter]);

  useEffect(() => {
    fetchContent();
  }, [fetchContent]);

  const totalPages = Math.ceil(total / 20);

  function handleAction(id: string, action: string) {
    if (action === 'HIDDEN' || action === 'REMOVED') {
      setConfirmAction({ id, action });
      return;
    }
    executeAction(id, action);
  }

  function executeAction(id: string, action: string) {
    if (!accessToken) return;
    setActionLoading(true);
    setError('');

    const promise =
      action === 'RESTORE'
        ? restoreContent(accessToken, id)
        : updateContentStatus(accessToken, id, action);

    promise
      .then(() => {
        setConfirmAction(null);
        fetchContent();
      })
      .catch((err) => setError(err.message))
      .finally(() => setActionLoading(false));
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Content</h1>
          <p className="mt-1 text-sm text-stone-500">
            {total} item{total !== 1 ? 's' : ''}
          </p>
        </div>
        <div className="flex gap-1 bg-stone-100 p-1 rounded-lg">
          {(
            [
              { value: 'all', label: 'All' },
              { value: 'ACTIVE', label: 'Active' },
              { value: 'FLAGGED', label: 'Flagged' },
              { value: 'HIDDEN', label: 'Hidden' },
              { value: 'REMOVED', label: 'Removed' },
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
                Type
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Creator
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Engagement
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Created
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-50">
            {items.map((item) => (
              <tr key={item.id} className="hover:bg-stone-50/50">
                <td className="px-4 py-3">
                  <ContentTypeBadge type={item.type} />
                </td>
                <td className="px-4 py-3 text-sm font-medium text-stone-900">
                  {item.creatorName}
                </td>
                <td className="px-4 py-3">
                  <ContentStatusBadge status={item.status} />
                </td>
                <td className="px-4 py-3 text-sm text-stone-500">
                  <span title="Likes">{item.likeCount ?? 0} likes</span>
                  {' \u00B7 '}
                  <span title="Comments">
                    {item.commentCount ?? 0} comments
                  </span>
                  {' \u00B7 '}
                  <span title="Views">{item.viewCount ?? 0} views</span>
                </td>
                <td className="px-4 py-3 text-sm text-stone-500">
                  {new Date(item.createdAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <div className="flex gap-1">
                    {item.status !== 'HIDDEN' && item.status !== 'REMOVED' && (
                      <button
                        onClick={() => handleAction(item.id, 'HIDDEN')}
                        className="px-2 py-1 text-xs font-medium text-yellow-700 bg-yellow-50 rounded hover:bg-yellow-100 transition-colors"
                      >
                        Hide
                      </button>
                    )}
                    {item.status !== 'REMOVED' && (
                      <button
                        onClick={() => handleAction(item.id, 'REMOVED')}
                        className="px-2 py-1 text-xs font-medium text-red-700 bg-red-50 rounded hover:bg-red-100 transition-colors"
                      >
                        Remove
                      </button>
                    )}
                    {(item.status === 'HIDDEN' ||
                      item.status === 'REMOVED') && (
                      <button
                        onClick={() => handleAction(item.id, 'RESTORE')}
                        className="px-2 py-1 text-xs font-medium text-green-700 bg-green-50 rounded hover:bg-green-100 transition-colors"
                      >
                        Restore
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  No content found
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
              Confirm {confirmAction.action === 'HIDDEN' ? 'Hide' : 'Remove'}
            </h3>
            <p className="mt-2 text-sm text-stone-500">
              Are you sure you want to{' '}
              {confirmAction.action === 'HIDDEN' ? 'hide' : 'remove'} this
              content? This action can be reversed by restoring the content.
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
                  confirmAction.action === 'REMOVED'
                    ? 'bg-red-600 hover:bg-red-700'
                    : 'bg-yellow-600 hover:bg-yellow-700'
                }`}
              >
                {actionLoading
                  ? 'Processing...'
                  : confirmAction.action === 'HIDDEN'
                    ? 'Hide Content'
                    : 'Remove Content'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function ContentTypeBadge({ type }: { type: string }) {
  const styles: Record<string, string> = {
    POST: 'bg-blue-50 text-blue-700',
    STORY: 'bg-purple-50 text-purple-700',
    COMMENT: 'bg-stone-100 text-stone-600',
    MEDIA: 'bg-amber-50 text-amber-700',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[type] || 'bg-stone-100 text-stone-600'}`}
    >
      {type}
    </span>
  );
}

function ContentStatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    ACTIVE: 'bg-green-50 text-green-700',
    FLAGGED: 'bg-orange-50 text-orange-700',
    HIDDEN: 'bg-yellow-50 text-yellow-700',
    REMOVED: 'bg-red-50 text-red-700',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[status] || 'bg-stone-100 text-stone-600'}`}
    >
      {status}
    </span>
  );
}
