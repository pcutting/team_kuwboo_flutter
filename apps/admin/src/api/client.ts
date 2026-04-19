const API_BASE = import.meta.env.VITE_API_URL || '/api';

interface RequestOptions {
  method?: string;
  body?: unknown;
  token?: string;
}

async function request<T>(path: string, opts: RequestOptions = {}): Promise<T> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  if (opts.token) {
    headers['Authorization'] = `Bearer ${opts.token}`;
  }

  const res = await fetch(`${API_BASE}${path}`, {
    method: opts.method || 'GET',
    headers,
    body: opts.body ? JSON.stringify(opts.body) : undefined,
  });

  if (!res.ok) {
    const error = await res.json().catch(() => ({ message: res.statusText }));
    throw new Error(error.message || `Request failed: ${res.status}`);
  }

  if (res.status === 204) {
    return undefined as T;
  }

  return res.json();
}

// Auth
export function sendOtp(phone: string) {
  return request('/auth/phone/send-otp', {
    method: 'POST',
    body: { phone },
  });
}

export function verifyOtp(phone: string, code: string) {
  return request<{
    data: {
      accessToken: string;
      refreshToken: string;
      user: { id: string; name: string; role: string; avatarUrl?: string };
      isNewUser: boolean;
    };
  }>('/auth/phone/verify-otp', {
    method: 'POST',
    body: { phone, code },
  });
}

interface AuthResponsePayload {
  data: {
    accessToken: string;
    refreshToken: string;
    user: { id: string; name: string; role: string; avatarUrl?: string };
    isNewUser: boolean;
  };
}

export function emailLogin(email: string, password: string) {
  return request<AuthResponsePayload>('/auth/email/login', {
    method: 'POST',
    body: { email, password },
  });
}

export function emailForgotPassword(email: string) {
  return request<{ data: { devCode?: string } }>(
    '/auth/email/password/forgot',
    {
      method: 'POST',
      body: { email },
    },
  );
}

export function emailResetPassword(
  email: string,
  code: string,
  newPassword: string,
) {
  return request<AuthResponsePayload>('/auth/email/password/reset', {
    method: 'POST',
    body: { email, code, newPassword },
  });
}

export function refreshTokens(accessToken: string, refreshToken: string) {
  return request<{ data: { accessToken: string; refreshToken: string } }>(
    '/auth/refresh',
    {
      method: 'POST',
      body: { refreshToken },
      token: accessToken,
    },
  );
}

// Admin
export function getStats(token: string) {
  return request<{ data: Record<string, number> }>('/admin/stats', { token });
}

export function listUsers(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/users${query}`, { token });
}

// Bots
export function getBotStats(token: string) {
  return request<{ data: Record<string, number> }>('/admin/bots/stats', {
    token,
  });
}

export function listBots(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/bots${query}`, { token });
}

// Content
export function listContent(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/content${query}`, { token });
}

export function listFlaggedContent(
  token: string,
  params?: Record<string, string>,
) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/content/flagged${query}`, { token });
}

export function updateContentStatus(
  token: string,
  id: string,
  status: string,
) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/content/${id}/status`,
    { method: 'PATCH', body: { status }, token },
  );
}

export function restoreContent(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/content/${id}/restore`,
    { method: 'POST', token },
  );
}

// Comments
export function listAdminComments(
  token: string,
  params?: Record<string, string>,
) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/comments${query}`, { token });
}

export function deleteComment(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/comments/${id}`,
    { method: 'DELETE', token },
  );
}

// User Detail
export function getUserDetail(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/users/${id}/detail`,
    { token },
  );
}

export function suspendUser(
  token: string,
  id: string,
  body: { reason: string; durationDays?: number },
) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/users/${id}/suspend`,
    { method: 'POST', body, token },
  );
}

export function warnUser(
  token: string,
  id: string,
  body: { message: string },
) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/users/${id}/warn`,
    { method: 'POST', body, token },
  );
}

export function forceLogout(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/users/${id}/sessions`,
    { method: 'DELETE', token },
  );
}

export function getUserContent(
  token: string,
  id: string,
  params?: Record<string, string>,
) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/users/${id}/content${query}`, { token });
}

export function getUserReports(
  token: string,
  id: string,
  params?: Record<string, string>,
) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/users/${id}/reports${query}`, { token });
}

export function searchUsers(
  token: string,
  body: Record<string, unknown>,
) {
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>('/admin/users/search', { method: 'POST', body, token });
}

// Reports
export function listReports(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/reports${query}`, { token });
}

export function enforceReport(
  token: string,
  id: string,
  body: { action: string; reason?: string; durationDays?: number },
) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/reports/${id}/enforce`,
    { method: 'POST', body, token },
  );
}

// Audit Log
export function getAuditLog(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/audit-log${query}`, { token });
}

// Analytics
export function getGrowthMetrics(token: string, days?: number) {
  const query = days ? `?days=${days}` : '';
  return request<{ data: Record<string, unknown> }>(
    `/admin/analytics/growth${query}`,
    { token },
  );
}

export function getEngagementMetrics(token: string) {
  return request<{ data: Record<string, unknown> }>(
    '/admin/analytics/engagement',
    { token },
  );
}

export function getContentBreakdown(token: string) {
  return request<{ data: Record<string, unknown> }>(
    '/admin/analytics/content',
    { token },
  );
}

export function getActiveUsers(token: string, days?: number) {
  const query = days ? `?days=${days}` : '';
  return request<{ data: Record<string, unknown> }>(
    `/admin/analytics/active-users${query}`,
    { token },
  );
}

// Sessions
export function getSessionStats(token: string) {
  return request<{ data: Record<string, unknown> }>(
    '/admin/sessions/stats',
    { token },
  );
}

// System
export function getSystemHealth(token: string) {
  return request<{ data: Record<string, unknown> }>(
    '/admin/system/health',
    { token },
  );
}

// Bot Detail
export function getBotDetail(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(`/admin/bots/${id}`, {
    token,
  });
}

export function getBotActivityStats(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/bots/${id}/activity/stats`,
    { token },
  );
}

export function resetBot(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/bots/${id}/reset`,
    { method: 'POST', token },
  );
}

export function startBot(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/bots/${id}/start`,
    { method: 'POST', token },
  );
}

export function stopBot(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/bots/${id}/stop`,
    { method: 'POST', token },
  );
}

export function pauseBot(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/bots/${id}/pause`,
    { method: 'POST', token },
  );
}

// Marketplace
export function listProducts(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/marketplace/products${query}`, { token });
}

export function updateProductStatus(
  token: string,
  id: string,
  status: string,
) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/marketplace/products/${id}/status`,
    { method: 'PATCH', body: { status }, token },
  );
}

export function listAuctions(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/marketplace/auctions${query}`, { token });
}

export function cancelAuction(token: string, id: string) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/marketplace/auctions/${id}/cancel`,
    { method: 'POST', token },
  );
}

// Sponsored
export function listCampaigns(token: string, params?: Record<string, string>) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/sponsored/campaigns${query}`, { token });
}

export function updateCampaignStatus(
  token: string,
  id: string,
  status: string,
) {
  return request<{ data: Record<string, unknown> }>(
    `/admin/sponsored/campaigns/${id}/status`,
    { method: 'PATCH', body: { status }, token },
  );
}

// Notifications
export function broadcastNotification(
  token: string,
  body: { title: string; message: string; roleFilter?: string },
) {
  return request<{ data: Record<string, unknown> }>(
    '/admin/notifications/broadcast',
    { method: 'POST', body, token },
  );
}

export function getBotActivity(
  token: string,
  id: string,
  params?: Record<string, string>,
) {
  const query = params ? '?' + new URLSearchParams(params).toString() : '';
  return request<{
    data: { items: Array<Record<string, unknown>>; total: number };
  }>(`/admin/bots/${id}/activity${query}`, { token });
}

// Interests (admin CRUD)

export interface AdminInterest {
  id: string;
  slug: string;
  label: string;
  category?: string | null;
  displayOrder: number;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export function listInterests(token: string) {
  return request<{ data: { interests: AdminInterest[] } }>('/admin/interests', {
    token,
  });
}

export function createInterest(
  token: string,
  body: {
    slug: string;
    label: string;
    category?: string;
    display_order?: number;
  },
) {
  return request<{ data: AdminInterest }>('/admin/interests', {
    method: 'POST',
    body,
    token,
  });
}

export function updateInterest(
  token: string,
  id: string,
  body: {
    label?: string;
    category?: string;
    display_order?: number;
    is_active?: boolean;
  },
) {
  return request<{ data: AdminInterest }>(`/admin/interests/${id}`, {
    method: 'PATCH',
    body,
    token,
  });
}

export function deleteInterest(token: string, id: string) {
  return request<void>(`/admin/interests/${id}`, {
    method: 'DELETE',
    token,
  });
}

export function reorderInterests(token: string, orderedIds: string[]) {
  return request<{ data: { interests: AdminInterest[] } }>(
    '/admin/interests/reorder',
    {
      method: 'POST',
      body: { ordered_ids: orderedIds },
      token,
    },
  );
}

// Credentials (admin scope — backend endpoint TODO)
// NOTE: The backend currently exposes /credentials only for the authenticated
// user (see apps/api/src/modules/credentials/credentials.controller.ts). Admin
// list/revoke endpoints scoped to an arbitrary user do not yet exist. The
// calls below target a proposed /admin/users/:id/credentials surface; they
// will 404 until the backend ships those endpoints.

export interface AdminCredential {
  id: string;
  type: string;
  identifier: string;
  verified_at?: string | null;
  is_primary: boolean;
  created_at?: string;
}

export function listUserCredentials(token: string, userId: string) {
  return request<{ credentials: AdminCredential[] }>(
    `/admin/users/${userId}/credentials`,
    { token },
  );
}

export function revokeUserCredential(
  token: string,
  userId: string,
  credentialId: string,
) {
  return request<void>(
    `/admin/users/${userId}/credentials/${credentialId}`,
    { method: 'DELETE', token },
  );
}
