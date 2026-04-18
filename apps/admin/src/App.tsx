import { Routes, Route } from 'react-router';
import { LandingPage } from './pages/LandingPage';
import { LoginPage } from './pages/LoginPage';
import { ForgotPasswordPage } from './pages/ForgotPasswordPage';
import { ResetPasswordPage } from './pages/ResetPasswordPage';
import { DashboardPage } from './pages/DashboardPage';
import { UsersPage } from './pages/UsersPage';
import { UserDetailPage } from './pages/UserDetailPage';
import { BotsPage } from './pages/BotsPage';
import { BotDetailPage } from './pages/BotDetailPage';
import { ContentPage } from './pages/ContentPage';
import { ReportsPage } from './pages/ReportsPage';
import { MarketplacePage } from './pages/MarketplacePage';
import { SponsoredPage } from './pages/SponsoredPage';
import { BroadcastPage } from './pages/BroadcastPage';
import { AuditLogPage } from './pages/AuditLogPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { SessionsPage } from './pages/SessionsPage';
import { SystemHealthPage } from './pages/SystemHealthPage';
import { InterestsPage } from './pages/InterestsPage';
import { AdminLayout } from './components/AdminLayout';
import { ProtectedRoute } from './components/ProtectedRoute';

export function App() {
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/forgot-password" element={<ForgotPasswordPage />} />
      <Route path="/reset-password" element={<ResetPasswordPage />} />

      {/* Protected admin routes */}
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="users/:id" element={<UserDetailPage />} />
        <Route path="content" element={<ContentPage />} />
        <Route path="bots" element={<BotsPage />} />
        <Route path="bots/:id" element={<BotDetailPage />} />
        <Route path="reports" element={<ReportsPage />} />
        <Route path="marketplace" element={<MarketplacePage />} />
        <Route path="sponsored" element={<SponsoredPage />} />
        <Route path="broadcast" element={<BroadcastPage />} />
        <Route path="audit-log" element={<AuditLogPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="sessions" element={<SessionsPage />} />
        <Route path="system" element={<SystemHealthPage />} />
        <Route path="interests" element={<InterestsPage />} />
      </Route>
    </Routes>
  );
}
