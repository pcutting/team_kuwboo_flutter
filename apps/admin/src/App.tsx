import { Routes, Route } from 'react-router';
import { LandingPage } from './pages/LandingPage';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { UsersPage } from './pages/UsersPage';
import { UserDetailPage } from './pages/UserDetailPage';
import { BotsPage } from './pages/BotsPage';
import { ContentPage } from './pages/ContentPage';
import { ReportsPage } from './pages/ReportsPage';
import { MarketplacePage } from './pages/MarketplacePage';
import { SponsoredPage } from './pages/SponsoredPage';
import { BroadcastPage } from './pages/BroadcastPage';
import { AuditLogPage } from './pages/AuditLogPage';
import { AdminLayout } from './components/AdminLayout';
import { ProtectedRoute } from './components/ProtectedRoute';

export function App() {
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />

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
        <Route path="reports" element={<ReportsPage />} />
        <Route path="marketplace" element={<MarketplacePage />} />
        <Route path="sponsored" element={<SponsoredPage />} />
        <Route path="broadcast" element={<BroadcastPage />} />
        <Route path="audit-log" element={<AuditLogPage />} />
      </Route>
    </Routes>
  );
}
