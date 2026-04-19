import { useEffect, useMemo, useState, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
  AdminInterest,
  createInterest,
  deleteInterest,
  listInterests,
  reorderInterests,
  updateInterest,
} from '../api/client';

type DrawerMode =
  | { kind: 'closed' }
  | { kind: 'create' }
  | { kind: 'edit'; interest: AdminInterest };

const SLUG_RE = /^[a-z0-9][a-z0-9-]*$/;

export function InterestsPage() {
  const { accessToken } = useAuth();
  const [items, setItems] = useState<AdminInterest[]>([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [categoryFilter, setCategoryFilter] = useState<string>('');
  const [drawer, setDrawer] = useState<DrawerMode>({ kind: 'closed' });

  const refresh = useCallback(() => {
    if (!accessToken) return;
    setLoading(true);
    listInterests(accessToken)
      .then((res) => {
        const sorted = [...res.data.interests].sort(
          (a, b) => a.displayOrder - b.displayOrder,
        );
        setItems(sorted);
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [accessToken]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const categories = useMemo(() => {
    const set = new Set<string>();
    items.forEach((i) => {
      if (i.category) set.add(i.category);
    });
    return Array.from(set).sort();
  }, [items]);

  const visibleItems = useMemo(() => {
    if (!categoryFilter) return items;
    return items.filter((i) => (i.category || '') === categoryFilter);
  }, [items, categoryFilter]);

  const handleDelete = useCallback(
    async (interest: AdminInterest) => {
      if (!accessToken) return;
      if (
        !confirm(
          `Soft-delete "${interest.label}"? It will be marked inactive and hidden from users.`,
        )
      ) {
        return;
      }
      try {
        await deleteInterest(accessToken, interest.id);
        refresh();
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to delete');
      }
    },
    [accessToken, refresh],
  );

  const handleRestore = useCallback(
    async (interest: AdminInterest) => {
      if (!accessToken) return;
      try {
        await updateInterest(accessToken, interest.id, { is_active: true });
        refresh();
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to restore');
      }
    },
    [accessToken, refresh],
  );

  const handleMove = useCallback(
    async (index: number, direction: -1 | 1) => {
      if (!accessToken) return;
      const next = [...items];
      const target = index + direction;
      if (target < 0 || target >= next.length) return;
      [next[index], next[target]] = [next[target], next[index]];
      const orderedIds = next.map((i) => i.id);
      // Optimistic update
      setItems(next.map((it, idx) => ({ ...it, displayOrder: idx })));
      try {
        await reorderInterests(accessToken, orderedIds);
        refresh();
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to reorder');
        refresh();
      }
    },
    [accessToken, items, refresh],
  );

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-stone-900">Interests</h1>
          <p className="mt-1 text-sm text-stone-500">
            {items.length} interest{items.length !== 1 ? 's' : ''} &middot;{' '}
            {items.filter((i) => i.isActive).length} active
          </p>
        </div>
        <div className="flex items-center gap-2">
          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-amber-500"
          >
            <option value="">All categories</option>
            {categories.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
          <button
            onClick={() => setDrawer({ kind: 'create' })}
            className="px-3 py-1.5 text-sm font-medium text-white bg-amber-600 rounded-lg hover:bg-amber-700"
          >
            + New interest
          </button>
        </div>
      </div>

      {error && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700 flex items-center justify-between">
          <span>{error}</span>
          <button
            onClick={() => setError('')}
            className="text-red-700 hover:text-red-900 font-medium"
          >
            Dismiss
          </button>
        </div>
      )}

      <div className="mt-6 bg-white rounded-xl border border-stone-200 overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-stone-100">
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider w-16">
                Order
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Label
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Slug
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Category
              </th>
              <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-4 py-3 text-right text-xs font-semibold text-stone-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-stone-50">
            {visibleItems.map((interest) => {
              const fullIndex = items.findIndex((i) => i.id === interest.id);
              return (
                <tr key={interest.id} className="hover:bg-stone-50/50">
                  <td className="px-4 py-3 text-sm text-stone-500 font-mono">
                    {interest.displayOrder}
                  </td>
                  <td className="px-4 py-3 text-sm font-medium text-stone-900">
                    {interest.label}
                  </td>
                  <td className="px-4 py-3 text-sm text-stone-500 font-mono">
                    {interest.slug}
                  </td>
                  <td className="px-4 py-3 text-sm text-stone-500">
                    {interest.category || '\u2014'}
                  </td>
                  <td className="px-4 py-3">
                    {interest.isActive ? (
                      <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-green-50 text-green-700">
                        Active
                      </span>
                    ) : (
                      <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-stone-100 text-stone-500">
                        Inactive
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => handleMove(fullIndex, -1)}
                        disabled={fullIndex <= 0 || !!categoryFilter}
                        title={
                          categoryFilter
                            ? 'Clear filter to reorder'
                            : 'Move up'
                        }
                        className="p-1.5 text-stone-500 hover:text-stone-900 hover:bg-stone-100 rounded disabled:opacity-30 disabled:cursor-not-allowed"
                      >
                        <ArrowUpIcon />
                      </button>
                      <button
                        onClick={() => handleMove(fullIndex, 1)}
                        disabled={
                          fullIndex >= items.length - 1 || !!categoryFilter
                        }
                        title={
                          categoryFilter
                            ? 'Clear filter to reorder'
                            : 'Move down'
                        }
                        className="p-1.5 text-stone-500 hover:text-stone-900 hover:bg-stone-100 rounded disabled:opacity-30 disabled:cursor-not-allowed"
                      >
                        <ArrowDownIcon />
                      </button>
                      <button
                        onClick={() =>
                          setDrawer({ kind: 'edit', interest })
                        }
                        className="px-2 py-1 text-xs font-medium text-stone-600 hover:text-stone-900 hover:bg-stone-100 rounded"
                      >
                        Edit
                      </button>
                      {interest.isActive ? (
                        <button
                          onClick={() => handleDelete(interest)}
                          className="px-2 py-1 text-xs font-medium text-red-700 hover:bg-red-50 rounded"
                        >
                          Delete
                        </button>
                      ) : (
                        <button
                          onClick={() => handleRestore(interest)}
                          className="px-2 py-1 text-xs font-medium text-green-700 hover:bg-green-50 rounded"
                        >
                          Restore
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              );
            })}
            {!loading && visibleItems.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  No interests found
                </td>
              </tr>
            )}
            {loading && items.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-sm text-stone-400"
                >
                  Loading interests...
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {drawer.kind !== 'closed' && (
        <InterestDrawer
          mode={drawer}
          existingCategories={categories}
          existingSlugs={items.map((i) => i.slug)}
          maxOrder={items.reduce(
            (acc, i) => Math.max(acc, i.displayOrder),
            -1,
          )}
          onClose={() => setDrawer({ kind: 'closed' })}
          onSaved={() => {
            setDrawer({ kind: 'closed' });
            refresh();
          }}
        />
      )}
    </div>
  );
}

interface DrawerProps {
  mode: Exclude<DrawerMode, { kind: 'closed' }>;
  existingCategories: string[];
  existingSlugs: string[];
  maxOrder: number;
  onClose: () => void;
  onSaved: () => void;
}

function InterestDrawer({
  mode,
  existingCategories,
  existingSlugs,
  maxOrder,
  onClose,
  onSaved,
}: DrawerProps) {
  const { accessToken } = useAuth();
  const initial =
    mode.kind === 'edit'
      ? mode.interest
      : {
          slug: '',
          label: '',
          category: '',
          displayOrder: maxOrder + 1,
        };
  const [slug, setSlug] = useState(initial.slug);
  const [label, setLabel] = useState(initial.label);
  const [category, setCategory] = useState(initial.category || '');
  const [displayOrder, setDisplayOrder] = useState(
    String(initial.displayOrder ?? maxOrder + 1),
  );
  const [isActive, setIsActive] = useState(
    mode.kind === 'edit' ? mode.interest.isActive : true,
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const slugValid = SLUG_RE.test(slug);
  const slugDuplicate =
    mode.kind === 'create' && existingSlugs.includes(slug);
  const labelValid = label.trim().length > 0 && label.length <= 120;
  const canSave =
    (mode.kind === 'edit' || (slugValid && !slugDuplicate)) && labelValid;

  async function handleSave() {
    if (!accessToken) return;
    setSaving(true);
    setError('');
    try {
      if (mode.kind === 'create') {
        await createInterest(accessToken, {
          slug,
          label: label.trim(),
          category: category.trim() || undefined,
          display_order: displayOrder ? Number(displayOrder) : undefined,
        });
      } else {
        await updateInterest(accessToken, mode.interest.id, {
          label: label.trim(),
          category: category.trim() || undefined,
          display_order: displayOrder ? Number(displayOrder) : undefined,
          is_active: isActive,
        });
      }
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative ml-auto w-full max-w-md h-full bg-white shadow-xl flex flex-col">
        <div className="p-5 border-b border-stone-100">
          <h2 className="text-lg font-semibold text-stone-900">
            {mode.kind === 'create' ? 'New interest' : 'Edit interest'}
          </h2>
          {mode.kind === 'edit' && (
            <p className="mt-0.5 text-xs text-stone-500 font-mono">
              {mode.interest.slug}
            </p>
          )}
        </div>
        <div className="flex-1 overflow-auto p-5 space-y-4">
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
              {error}
            </div>
          )}
          {mode.kind === 'create' && (
            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">
                Slug
              </label>
              <input
                type="text"
                value={slug}
                onChange={(e) => setSlug(e.target.value.toLowerCase())}
                placeholder="e.g. indie-music"
                className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 font-mono"
              />
              {slug && !slugValid && (
                <p className="mt-1 text-xs text-red-600">
                  Slug must be lowercase letters, digits, and hyphens.
                </p>
              )}
              {slugDuplicate && (
                <p className="mt-1 text-xs text-red-600">
                  A slug with this value already exists.
                </p>
              )}
            </div>
          )}
          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">
              Label
            </label>
            <input
              type="text"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="e.g. Indie Music"
              className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">
              Category
            </label>
            <input
              type="text"
              list="interest-categories"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              placeholder="e.g. Music"
              className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
            />
            <datalist id="interest-categories">
              {existingCategories.map((c) => (
                <option key={c} value={c} />
              ))}
            </datalist>
            <p className="mt-1 text-xs text-stone-400">
              Choose an existing category or type a new one.
            </p>
          </div>
          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">
              Display order
            </label>
            <input
              type="number"
              min="0"
              value={displayOrder}
              onChange={(e) => setDisplayOrder(e.target.value)}
              className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500"
            />
          </div>
          {mode.kind === 'edit' && (
            <label className="flex items-center gap-2 text-sm text-stone-700">
              <input
                type="checkbox"
                checked={isActive}
                onChange={(e) => setIsActive(e.target.checked)}
                className="rounded border-stone-300"
              />
              Active
            </label>
          )}
        </div>
        <div className="p-5 border-t border-stone-100 flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-stone-600 border border-stone-200 rounded-lg hover:bg-stone-50"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={!canSave || saving}
            className="px-4 py-2 text-sm font-medium text-white bg-amber-600 rounded-lg hover:bg-amber-700 disabled:opacity-50"
          >
            {saving ? 'Saving...' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  );
}

function ArrowUpIcon() {
  return (
    <svg
      className="w-3.5 h-3.5"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <line x1="12" y1="19" x2="12" y2="5" />
      <polyline points="5 12 12 5 19 12" />
    </svg>
  );
}

function ArrowDownIcon() {
  return (
    <svg
      className="w-3.5 h-3.5"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <line x1="12" y1="5" x2="12" y2="19" />
      <polyline points="19 12 12 19 5 12" />
    </svg>
  );
}
