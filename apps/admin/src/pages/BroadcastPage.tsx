import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { broadcastNotification } from '../api/client';

type RoleFilter = '' | 'USER' | 'MODERATOR' | 'ADMIN';

export function BroadcastPage() {
  const { accessToken } = useAuth();
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [roleFilter, setRoleFilter] = useState<RoleFilter>('');
  const [showConfirm, setShowConfirm] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  function handleSend() {
    if (!title.trim() || !message.trim()) {
      setError('Title and message are required');
      return;
    }
    setShowConfirm(true);
  }

  function executeSend() {
    if (!accessToken) return;
    setSending(true);
    setError('');
    setSuccess('');

    const body: { title: string; message: string; roleFilter?: string } = {
      title: title.trim(),
      message: message.trim(),
    };
    if (roleFilter) {
      body.roleFilter = roleFilter;
    }

    broadcastNotification(accessToken, body)
      .then(() => {
        setSuccess('Notification sent successfully');
        setTitle('');
        setMessage('');
        setRoleFilter('');
        setShowConfirm(false);
      })
      .catch((err) => {
        setError(err.message);
        setShowConfirm(false);
      })
      .finally(() => setSending(false));
  }

  const audienceLabel = roleFilter
    ? `${roleFilter.charAt(0)}${roleFilter.slice(1).toLowerCase()}s`
    : 'All Users';

  return (
    <div>
      <div>
        <h1 className="text-2xl font-bold text-stone-900">Broadcast</h1>
        <p className="mt-1 text-sm text-stone-500">
          Send notifications to users
        </p>
      </div>

      {error && (
        <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {success && (
        <div className="mt-4 p-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-700">
          {success}
        </div>
      )}

      <div className="mt-6 bg-white rounded-xl border border-stone-200 p-6">
        <div className="space-y-5">
          <div>
            <label
              htmlFor="broadcast-title"
              className="block text-sm font-medium text-stone-700 mb-1.5"
            >
              Title
            </label>
            <input
              id="broadcast-title"
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Notification title"
              className="w-full px-3 py-2 border border-stone-200 rounded-lg text-sm text-stone-900 placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500"
            />
          </div>

          <div>
            <label
              htmlFor="broadcast-message"
              className="block text-sm font-medium text-stone-700 mb-1.5"
            >
              Message
            </label>
            <textarea
              id="broadcast-message"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Write your notification message..."
              rows={5}
              className="w-full px-3 py-2 border border-stone-200 rounded-lg text-sm text-stone-900 placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 resize-none"
            />
          </div>

          <div>
            <label
              htmlFor="broadcast-role"
              className="block text-sm font-medium text-stone-700 mb-1.5"
            >
              Audience
            </label>
            <select
              id="broadcast-role"
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value as RoleFilter)}
              className="w-full px-3 py-2 border border-stone-200 rounded-lg text-sm text-stone-900 focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 bg-white"
            >
              <option value="">All Users</option>
              <option value="USER">Users</option>
              <option value="MODERATOR">Moderators</option>
              <option value="ADMIN">Admins</option>
            </select>
          </div>

          <div className="pt-2">
            <button
              onClick={handleSend}
              disabled={!title.trim() || !message.trim()}
              className="px-5 py-2.5 text-sm font-medium text-white bg-amber-600 hover:bg-amber-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Send Notification
            </button>
          </div>
        </div>
      </div>

      {/* Confirmation Dialog */}
      {showConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setShowConfirm(false)}
          />
          <div className="relative bg-white rounded-xl shadow-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-stone-900">
              Send Notification
            </h3>
            <p className="mt-2 text-sm text-stone-500">
              Send to <span className="font-medium text-stone-700">{audienceLabel}</span>?
            </p>
            <div className="mt-3 p-3 bg-stone-50 rounded-lg">
              <p className="text-sm font-medium text-stone-900">{title}</p>
              <p className="mt-1 text-sm text-stone-500 whitespace-pre-wrap">
                {message}
              </p>
            </div>
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={() => setShowConfirm(false)}
                className="px-4 py-2 text-sm font-medium text-stone-600 border border-stone-200 rounded-lg hover:bg-stone-50"
              >
                Cancel
              </button>
              <button
                onClick={executeSend}
                disabled={sending}
                className="px-4 py-2 text-sm font-medium text-white bg-amber-600 hover:bg-amber-700 rounded-lg disabled:opacity-50"
              >
                {sending ? 'Sending...' : 'Confirm Send'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
