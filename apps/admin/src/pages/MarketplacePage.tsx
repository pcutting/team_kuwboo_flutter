import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
  listProducts,
  updateProductStatus,
  listAuctions,
  cancelAuction,
} from '../api/client';

type Tab = 'products' | 'auctions';
type ProductStatus = 'all' | 'PENDING' | 'ACTIVE' | 'HIDDEN' | 'REMOVED';
type AuctionStatus = 'all' | 'ACTIVE' | 'ENDED' | 'CANCELLED';

interface ProductRecord {
  id: string;
  title: string;
  sellerName: string;
  price: number;
  status: string;
  createdAt: string;
}

interface AuctionRecord {
  id: string;
  title: string;
  sellerName: string;
  currentBid: number;
  endDate: string;
  status: string;
}

export function MarketplacePage() {
  const { accessToken } = useAuth();
  const [tab, setTab] = useState<Tab>('products');

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Marketplace</h1>
          <p className="mt-1 text-sm text-stone-500">
            Manage products and auctions
          </p>
        </div>
        <div className="flex gap-1 bg-stone-100 p-1 rounded-lg">
          {(
            [
              { value: 'products', label: 'Products' },
              { value: 'auctions', label: 'Auctions' },
            ] as const
          ).map((t) => (
            <button
              key={t.value}
              onClick={() => setTab(t.value)}
              className={`px-3 py-1.5 text-xs font-medium rounded-md transition-colors ${
                tab === t.value
                  ? 'bg-white text-stone-900 shadow-sm'
                  : 'text-stone-500 hover:text-stone-700'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {tab === 'products' ? (
        <ProductsSection accessToken={accessToken} />
      ) : (
        <AuctionsSection accessToken={accessToken} />
      )}
    </div>
  );
}

function ProductsSection({ accessToken }: { accessToken: string | null }) {
  const [items, setItems] = useState<ProductRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<ProductStatus>('all');
  const [error, setError] = useState('');
  const [confirmAction, setConfirmAction] = useState<{
    id: string;
    action: string;
  } | null>(null);
  const [actionLoading, setActionLoading] = useState(false);

  const fetchProducts = useCallback(() => {
    if (!accessToken) return;

    const params: Record<string, string> = { page: String(page), limit: '20' };
    if (filter !== 'all') params.status = filter;

    listProducts(accessToken, params)
      .then((res) => {
        setItems(res.data.items as unknown as ProductRecord[]);
        setTotal(res.data.total);
      })
      .catch((err) => setError(err.message));
  }, [accessToken, page, filter]);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

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

    updateProductStatus(accessToken, id, action)
      .then(() => {
        setConfirmAction(null);
        fetchProducts();
      })
      .catch((err) => setError(err.message))
      .finally(() => setActionLoading(false));
  }

  return (
    <>
      <div className="mt-4 flex justify-end">
        <div className="flex gap-1 bg-stone-100 p-1 rounded-lg">
          {(
            [
              { value: 'all', label: 'All' },
              { value: 'PENDING', label: 'Pending' },
              { value: 'ACTIVE', label: 'Active' },
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

      <div className="mt-4 bg-white rounded-xl border border-stone-200 overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-stone-100">
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Title
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Seller
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Price
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Status
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
                <td className="px-4 py-3 text-sm font-medium text-stone-900">
                  {item.title}
                </td>
                <td className="px-4 py-3 text-sm text-stone-600">
                  {item.sellerName}
                </td>
                <td className="px-4 py-3 text-sm text-stone-600">
                  ${item.price?.toLocaleString() ?? '0'}
                </td>
                <td className="px-4 py-3">
                  <StatusBadge status={item.status} />
                </td>
                <td className="px-4 py-3 text-sm text-stone-500">
                  {new Date(item.createdAt).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <div className="flex gap-1">
                    {item.status === 'PENDING' && (
                      <button
                        onClick={() => handleAction(item.id, 'ACTIVE')}
                        className="px-2 py-1 text-xs font-medium text-green-700 bg-green-50 rounded hover:bg-green-100 transition-colors"
                      >
                        Approve
                      </button>
                    )}
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
                  No products found
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
              product?
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
                    ? 'Hide Product'
                    : 'Remove Product'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

function AuctionsSection({ accessToken }: { accessToken: string | null }) {
  const [items, setItems] = useState<AuctionRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filter, setFilter] = useState<AuctionStatus>('all');
  const [error, setError] = useState('');
  const [confirmCancel, setConfirmCancel] = useState<string | null>(null);
  const [actionLoading, setActionLoading] = useState(false);

  const fetchAuctions = useCallback(() => {
    if (!accessToken) return;

    const params: Record<string, string> = { page: String(page), limit: '20' };
    if (filter !== 'all') params.status = filter;

    listAuctions(accessToken, params)
      .then((res) => {
        setItems(res.data.items as unknown as AuctionRecord[]);
        setTotal(res.data.total);
      })
      .catch((err) => setError(err.message));
  }, [accessToken, page, filter]);

  useEffect(() => {
    fetchAuctions();
  }, [fetchAuctions]);

  const totalPages = Math.ceil(total / 20);

  function handleCancel(id: string) {
    if (!accessToken) return;
    setActionLoading(true);
    setError('');

    cancelAuction(accessToken, id)
      .then(() => {
        setConfirmCancel(null);
        fetchAuctions();
      })
      .catch((err) => setError(err.message))
      .finally(() => setActionLoading(false));
  }

  return (
    <>
      <div className="mt-4 flex justify-end">
        <div className="flex gap-1 bg-stone-100 p-1 rounded-lg">
          {(
            [
              { value: 'all', label: 'All' },
              { value: 'ACTIVE', label: 'Active' },
              { value: 'ENDED', label: 'Ended' },
              { value: 'CANCELLED', label: 'Cancelled' },
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

      <div className="mt-4 bg-white rounded-xl border border-stone-200 overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-stone-100">
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Title
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Seller
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Current Bid
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                End Date
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Status
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
                  {item.title}
                </td>
                <td className="px-4 py-3 text-sm text-stone-600">
                  {item.sellerName}
                </td>
                <td className="px-4 py-3 text-sm text-stone-600">
                  ${item.currentBid?.toLocaleString() ?? '0'}
                </td>
                <td className="px-4 py-3 text-sm text-stone-500">
                  {new Date(item.endDate).toLocaleDateString()}
                </td>
                <td className="px-4 py-3">
                  <StatusBadge status={item.status} />
                </td>
                <td className="px-4 py-3">
                  {item.status === 'ACTIVE' && (
                    <button
                      onClick={() => setConfirmCancel(item.id)}
                      className="px-2 py-1 text-xs font-medium text-red-700 bg-red-50 rounded hover:bg-red-100 transition-colors"
                    >
                      Cancel
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  No auctions found
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

      {/* Cancel Confirmation Dialog */}
      {confirmCancel && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setConfirmCancel(null)}
          />
          <div className="relative bg-white rounded-xl shadow-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-stone-900">
              Cancel Auction
            </h3>
            <p className="mt-2 text-sm text-stone-500">
              Are you sure you want to cancel this auction? This action cannot
              be undone.
            </p>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setConfirmCancel(null)}
                className="px-4 py-2 text-sm font-medium text-stone-600 border border-stone-200 rounded-lg hover:bg-stone-50"
              >
                Keep Active
              </button>
              <button
                onClick={() => handleCancel(confirmCancel)}
                disabled={actionLoading}
                className="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg disabled:opacity-50"
              >
                {actionLoading ? 'Processing...' : 'Cancel Auction'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    ACTIVE: 'bg-green-50 text-green-700',
    PENDING: 'bg-amber-50 text-amber-700',
    HIDDEN: 'bg-yellow-50 text-yellow-700',
    REMOVED: 'bg-red-50 text-red-700',
    ENDED: 'bg-stone-100 text-stone-600',
    CANCELLED: 'bg-red-50 text-red-700',
  };
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[status] || 'bg-stone-100 text-stone-600'}`}
    >
      {status}
    </span>
  );
}
