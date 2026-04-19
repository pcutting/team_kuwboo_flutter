import { useEffect, useState, useCallback } from 'react';
import { useParams, Link } from 'react-router';
import { useAuth } from '../contexts/AuthContext';
import {
  getUserDetail,
  suspendUser,
  warnUser,
  forceLogout,
  getUserContent,
  getUserReports,
  listUserCredentials,
  revokeUserCredential,
  AdminCredential,
} from '../api/client';

interface UserDetail {
  id: string;
  name?: string | null;
  username?: string | null;
  phone?: string | null;
  email?: string | null;
  role: string;
  status: string;
  isBot: boolean;
  createdAt: string;
  contentCount: number;
  commentCount: number;
  connectionsCount: number;
  reportsCount: number;
}

interface ContentRecord {
  id: string;
  type: string;
  status: string;
  likeCount: number;
  commentCount: number;
  viewCount: number;
  createdAt: string;
}

interface ReportRecord {
  id: string;
  targetType: string;
  reason: string;
  reporterName: string;
  status: string;
  createdAt: string;
}

type ActiveTab = 'content' | 'reports' | 'credentials';

export function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [user, setUser] = useState<UserDetail | null>(null);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<ActiveTab>('content');

  // Tab data
  const [contentItems, setContentItems] = useState<ContentRecord[]>([]);
  const [contentTotal, setContentTotal] = useState(0);
  const [contentPage, setContentPage] = useState(1);
  const [reportItems, setReportItems] = useState<ReportRecord[]>([]);
  const [reportTotal, setReportTotal] = useState(0);
  const [reportPage, setReportPage] = useState(1);
  const [credentials, setCredentials] = useState<AdminCredential[]>([]);
  const [credentialsError, setCredentialsError] = useState('');
  const [credentialsLoading, setCredentialsLoading] = useState(false);

  // Dialogs
  const [showSuspendDialog, setShowSuspendDialog] = useState(false);
  const [showWarnDialog, setShowWarnDialog] = useState(false);
  const [suspendReason, setSuspendReason] = useState('');
  const [suspendDuration, setSuspendDuration] = useState('');
  const [warnMessage, setWarnMessage] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  const fetchUser = useCallback(() => {
    if (!accessToken || !id) return;
    getUserDetail(accessToken, id)
      .then((res) => setUser(res.data as unknown as UserDetail))
      .catch((err) => setError(err.message));
  }, [accessToken, id]);

  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  const fetchCredentials = useCallback(() => {
    if (!accessToken || !id) return;
    setCredentialsLoading(true);
    setCredentialsError('');
    listUserCredentials(accessToken, id)
      .then((res) => setCredentials(res.credentials))
      .catch((err) =>
        setCredentialsError(
          err instanceof Error ? err.message : 'Failed to load credentials',
        ),
      )
      .finally(() => setCredentialsLoading(false));
  }, [accessToken, id]);

  async function handleRevokeCredential(credentialId: string) {
    if (!accessToken || !id) return;
    if (!confirm('Revoke this credential? The user will lose this sign-in method.')) {
      return;
    }
    try {
      await revokeUserCredential(accessToken, id, credentialId);
      fetchCredentials();
    } catch (err) {
      setCredentialsError(
        err instanceof Error ? err.message : 'Failed to revoke credential',
      );
    }
  }

  useEffect(() => {
    if (!accessToken || !id) return;
    if (activeTab === 'credentials') {
      fetchCredentials();
      return;
    }
    if (activeTab === 'content') {
      getUserContent(accessToken, id, {
        page: String(contentPage),
        limit: '10',
      })
        .then((res) => {
          setContentItems(res.data.items as unknown as ContentRecord[]);
          setContentTotal(res.data.total);
        })
        .catch(() => {});
    } else {
      getUserReports(accessToken, id, {
        page: String(reportPage),
        limit: '10',
      })
        .then((res) => {
          setReportItems(res.data.items as unknown as ReportRecord[]);
          setReportTotal(res.data.total);
        })
        .catch(() => {});
    }
  }, [accessToken, id, activeTab, contentPage, reportPage]);

  async function handleSuspend() {
    if (!accessToken || !id) return;
    setActionLoading(true);
    try {
      const body: { reason: string; durationDays?: number } = {
        reason: suspendReason,
      };
      if (suspendDuration) body.durationDays = Number(suspendDuration);
      await suspendUser(accessToken, id, body);
      setShowSuspendDialog(false);
      setSuspendReason('');
      setSuspendDuration('');
      fetchUser();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to suspend user');
    } finally {
      setActionLoading(false);
    }
  }

  async function handleWarn() {
    if (!accessToken || !id) return;
    setActionLoading(true);
    try {
      await warnUser(accessToken, id, { message: warnMessage });
      setShowWarnDialog(false);
      setWarnMessage('');
      fetchUser();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to warn user');
    } finally {
      setActionLoading(false);
    }
  }

  async function handleForceLogout() {
    if (!accessToken || !id) return;
    setActionLoading(true);
    try {
      await forceLogout(accessToken, id);
      fetchUser();
    } catch (err) {
      setError(
        err instanceof Error ? err.message : 'Failed to force logout',
      );
    } finally {
      setActionLoading(false);
    }
  }

  const contentTotalPages = Math.ceil(contentTotal / 10);
  const reportTotalPages = Math.ceil(reportTotal / 10);

  if (!user && !error) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-sm text-stone-400">Loading user details...</p>
      </div>
    );
  }

  return (
    <div>
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm text-stone-500 mb-6">
        <Link
          to="/dashboard/users"
          className="hover:text-stone-700 transition-colors"
        >
          Users
        </Link>
        <span>/</span>
        <span className="text-stone-900">{user?.name || user?.username || user?.email || user?.phone || 'User'}</span>
      </div>

      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {user && (
        <>
          {/* Profile header */}
          <div className="bg-white rounded-xl border border-stone-200 p-6">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 bg-stone-200 rounded-full flex items-center justify-center text-xl font-bold text-stone-600">
                  {(user.name?.charAt(0) ??
                    user.username?.charAt(0) ??
                    user.email?.charAt(0) ??
                    user.phone?.charAt(0) ??
                    '?').toUpperCase()}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-2xl font-bold text-stone-900">
                      {user.name || user.username || user.email || user.phone || 'Unnamed user'}
                    </h1>
                    <StatusBadge status={user.status} />
                    {user.isBot && (
                      <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-purple-50 text-purple-600">
                        Bot
                      </span>
                    )}
                  </div>
                  <div className="mt-1 flex items-center gap-4 text-sm text-stone-500">
                    {user.phone && <span>{user.phone}</span>}
                    {user.email && <span>{user.email}</span>}
                    <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-stone-100 text-stone-600">
                      {user.role}
                    </span>
                  </div>
                  <p className="mt-1 text-xs text-stone-400">
                    Joined {new Date(user.createdAt).toLocaleDateString()}
                  </p>
                </div>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowSuspendDialog(true)}
                  className="px-3 py-1.5 text-xs font-medium text-yellow-700 bg-yellow-50 border border-yellow-200 rounded-lg hover:bg-yellow-100 transition-colors"
                >
                  Suspend
                </button>
                <button
                  onClick={() => setShowWarnDialog(true)}
                  className="px-3 py-1.5 text-xs font-medium text-orange-700 bg-orange-50 border border-orange-200 rounded-lg hover:bg-orange-100 transition-colors"
                >
                  Warn
                </button>
                <button
                  onClick={handleForceLogout}
                  disabled={actionLoading}
                  className="px-3 py-1.5 text-xs font-medium text-red-700 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 disabled:opacity-50 transition-colors"
                >
                  Force Logout
                </button>
              </div>
            </div>
          </div>

          {/* Stats cards */}
          <div className="mt-6 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              label="Content"
              value={user.contentCount}
              accent="text-blue-700"
            />
            <StatCard
              label="Comments"
              value={user.commentCount}
              accent="text-purple-700"
            />
            <StatCard
              label="Connections"
              value={user.connectionsCount}
              accent="text-green-700"
            />
            <StatCard
              label="Reports Against"
              value={user.reportsCount}
              accent="text-red-700"
            />
          </div>

          {/* Tabs */}
          <div className="mt-8">
            <div className="flex gap-1 bg-stone-100 p-1 rounded-lg w-fit">
              {(
                [
                  { value: 'content', label: 'Content' },
                  { value: 'reports', label: 'Reports' },
                  { value: 'credentials', label: 'Credentials' },
                ] as const
              ).map((tab) => (
                <button
                  key={tab.value}
                  onClick={() => setActiveTab(tab.value)}
                  className={`px-4 py-1.5 text-xs font-medium rounded-md transition-colors ${
                    activeTab === tab.value
                      ? 'bg-white text-stone-900 shadow-sm'
                      : 'text-stone-500 hover:text-stone-700'
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            {activeTab === 'content' && (
              <div className="mt-4 bg-white rounded-xl border border-stone-200 overflow-hidden">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-stone-100">
                      <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Type
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
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-stone-50">
                    {contentItems.map((item) => (
                      <tr key={item.id} className="hover:bg-stone-50/50">
                        <td className="px-4 py-3">
                          <ContentTypeBadge type={item.type} />
                        </td>
                        <td className="px-4 py-3">
                          <StatusBadge status={item.status} />
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-500">
                          {item.likeCount ?? 0} likes &middot;{' '}
                          {item.commentCount ?? 0} comments &middot;{' '}
                          {item.viewCount ?? 0} views
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-500">
                          {new Date(item.createdAt).toLocaleDateString()}
                        </td>
                      </tr>
                    ))}
                    {contentItems.length === 0 && (
                      <tr>
                        <td
                          colSpan={4}
                          className="px-4 py-12 text-center text-sm text-stone-400"
                        >
                          No content found
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
                {contentTotalPages > 1 && (
                  <div className="px-4 py-3 border-t border-stone-100 flex items-center justify-between">
                    <p className="text-sm text-stone-500">
                      Page {contentPage} of {contentTotalPages}
                    </p>
                    <div className="flex gap-2">
                      <button
                        onClick={() =>
                          setContentPage((p) => Math.max(1, p - 1))
                        }
                        disabled={contentPage <= 1}
                        className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Previous
                      </button>
                      <button
                        onClick={() =>
                          setContentPage((p) =>
                            Math.min(contentTotalPages, p + 1),
                          )
                        }
                        disabled={contentPage >= contentTotalPages}
                        className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Next
                      </button>
                    </div>
                  </div>
                )}
              </div>
            )}

            {activeTab === 'credentials' && (
              <div className="mt-4 bg-white rounded-xl border border-stone-200 overflow-hidden">
                {credentialsError && (
                  <div className="m-4 p-3 bg-amber-50 border border-amber-200 rounded-lg text-sm text-amber-800">
                    <p className="font-medium">
                      Could not load credentials
                    </p>
                    <p className="mt-1 text-xs">{credentialsError}</p>
                    <p className="mt-2 text-xs text-amber-700">
                      Backend endpoint TODO: <code className="font-mono">GET /admin/users/:id/credentials</code>{' '}
                      and <code className="font-mono">DELETE /admin/users/:id/credentials/:credentialId</code>{' '}
                      are not yet implemented. Filed separately.
                    </p>
                  </div>
                )}
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-stone-100">
                      <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Type
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Identifier
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Verified
                      </th>
                      <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Primary
                      </th>
                      <th className="px-4 py-3 text-right text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-stone-50">
                    {credentials.map((cred) => (
                      <tr key={cred.id} className="hover:bg-stone-50/50">
                        <td className="px-4 py-3">
                          <CredentialTypeBadge type={cred.type} />
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-900 font-mono">
                          {cred.identifier}
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-500">
                          {cred.verified_at
                            ? new Date(cred.verified_at).toLocaleDateString()
                            : '\u2014'}
                        </td>
                        <td className="px-4 py-3">
                          {cred.is_primary ? (
                            <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-amber-50 text-amber-700">
                              Primary
                            </span>
                          ) : (
                            <span className="text-xs text-stone-400">
                              &mdash;
                            </span>
                          )}
                        </td>
                        <td className="px-4 py-3 text-right">
                          <button
                            onClick={() => handleRevokeCredential(cred.id)}
                            className="px-2 py-1 text-xs font-medium text-red-700 hover:bg-red-50 rounded"
                          >
                            Revoke
                          </button>
                        </td>
                      </tr>
                    ))}
                    {!credentialsLoading &&
                      credentials.length === 0 &&
                      !credentialsError && (
                        <tr>
                          <td
                            colSpan={5}
                            className="px-4 py-12 text-center text-sm text-stone-400"
                          >
                            No credentials found
                          </td>
                        </tr>
                      )}
                    {credentialsLoading && (
                      <tr>
                        <td
                          colSpan={5}
                          className="px-4 py-12 text-center text-sm text-stone-400"
                        >
                          Loading credentials...
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            )}

            {activeTab === 'reports' && (
              <div className="mt-4 bg-white rounded-xl border border-stone-200 overflow-hidden">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-stone-100">
                      <th className="px-4 py-3 text-left text-xs font-semibold text-stone-500 uppercase tracking-wider">
                        Target Type
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
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-stone-50">
                    {reportItems.map((report) => (
                      <tr key={report.id} className="hover:bg-stone-50/50">
                        <td className="px-4 py-3">
                          <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-stone-100 text-stone-600">
                            {report.targetType}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-900">
                          {report.reason}
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-500">
                          {report.reporterName}
                        </td>
                        <td className="px-4 py-3">
                          <ReportStatusBadge status={report.status} />
                        </td>
                        <td className="px-4 py-3 text-sm text-stone-500">
                          {new Date(report.createdAt).toLocaleDateString()}
                        </td>
                      </tr>
                    ))}
                    {reportItems.length === 0 && (
                      <tr>
                        <td
                          colSpan={5}
                          className="px-4 py-12 text-center text-sm text-stone-400"
                        >
                          No reports found
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
                {reportTotalPages > 1 && (
                  <div className="px-4 py-3 border-t border-stone-100 flex items-center justify-between">
                    <p className="text-sm text-stone-500">
                      Page {reportPage} of {reportTotalPages}
                    </p>
                    <div className="flex gap-2">
                      <button
                        onClick={() =>
                          setReportPage((p) => Math.max(1, p - 1))
                        }
                        disabled={reportPage <= 1}
                        className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Previous
                      </button>
                      <button
                        onClick={() =>
                          setReportPage((p) =>
                            Math.min(reportTotalPages, p + 1),
                          )
                        }
                        disabled={reportPage >= reportTotalPages}
                        className="px-3 py-1.5 text-sm border border-stone-200 rounded-lg hover:bg-stone-50 disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Next
                      </button>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        </>
      )}

      {/* Suspend Dialog */}
      {showSuspendDialog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setShowSuspendDialog(false)}
          />
          <div className="relative bg-white rounded-xl shadow-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-stone-900">
              Suspend User
            </h3>
            <p className="mt-1 text-sm text-stone-500">
              Suspend {user?.name} from the platform.
            </p>
            <div className="mt-4 space-y-3">
              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Reason
                </label>
                <input
                  type="text"
                  value={suspendReason}
                  onChange={(e) => setSuspendReason(e.target.value)}
                  placeholder="Reason for suspension..."
                  className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Duration (days, optional)
                </label>
                <input
                  type="number"
                  value={suspendDuration}
                  onChange={(e) => setSuspendDuration(e.target.value)}
                  placeholder="Leave empty for indefinite"
                  min="1"
                  className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                />
              </div>
            </div>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setShowSuspendDialog(false)}
                className="px-4 py-2 text-sm font-medium text-stone-600 border border-stone-200 rounded-lg hover:bg-stone-50"
              >
                Cancel
              </button>
              <button
                onClick={handleSuspend}
                disabled={actionLoading || !suspendReason}
                className="px-4 py-2 text-sm font-medium text-white bg-yellow-600 rounded-lg hover:bg-yellow-700 disabled:opacity-50"
              >
                {actionLoading ? 'Suspending...' : 'Suspend User'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Warn Dialog */}
      {showWarnDialog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setShowWarnDialog(false)}
          />
          <div className="relative bg-white rounded-xl shadow-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-stone-900">Warn User</h3>
            <p className="mt-1 text-sm text-stone-500">
              Send a warning to {user?.name}.
            </p>
            <div className="mt-4">
              <label className="block text-sm font-medium text-stone-700 mb-1">
                Message
              </label>
              <textarea
                value={warnMessage}
                onChange={(e) => setWarnMessage(e.target.value)}
                placeholder="Warning message..."
                rows={3}
                className="w-full px-3 py-2 text-sm border border-stone-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent resize-none"
              />
            </div>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setShowWarnDialog(false)}
                className="px-4 py-2 text-sm font-medium text-stone-600 border border-stone-200 rounded-lg hover:bg-stone-50"
              >
                Cancel
              </button>
              <button
                onClick={handleWarn}
                disabled={actionLoading || !warnMessage}
                className="px-4 py-2 text-sm font-medium text-white bg-orange-600 rounded-lg hover:bg-orange-700 disabled:opacity-50"
              >
                {actionLoading ? 'Sending...' : 'Send Warning'}
              </button>
            </div>
          </div>
        </div>
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

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    ACTIVE: 'bg-green-50 text-green-700',
    SUSPENDED: 'bg-yellow-50 text-yellow-700',
    BANNED: 'bg-red-50 text-red-700',
    DELETED: 'bg-stone-100 text-stone-500',
    FLAGGED: 'bg-orange-50 text-orange-700',
    HIDDEN: 'bg-stone-100 text-stone-500',
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

function CredentialTypeBadge({ type }: { type: string }) {
  const styles: Record<string, string> = {
    PHONE: 'bg-blue-50 text-blue-700',
    EMAIL: 'bg-purple-50 text-purple-700',
    APPLE: 'bg-stone-900 text-white',
    GOOGLE: 'bg-red-50 text-red-700',
    USERNAME: 'bg-green-50 text-green-700',
  };
  const upper = type.toUpperCase();
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full ${styles[upper] || 'bg-stone-100 text-stone-600'}`}
    >
      {upper}
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
