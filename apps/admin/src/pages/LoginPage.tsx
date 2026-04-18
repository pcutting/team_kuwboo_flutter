import { useState, type FormEvent } from 'react';
import { useNavigate, Link } from 'react-router';
import { useAuth } from '../contexts/AuthContext';
import { sendOtp, verifyOtp, emailLogin } from '../api/client';
import { PasswordInput } from '../components/PasswordInput';

type Method = 'email' | 'phone';
type PhoneStep = 'phone' | 'otp';

export function LoginPage() {
  const [method, setMethod] = useState<Method>('email');

  const [phoneStep, setPhoneStep] = useState<PhoneStep>('phone');
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState('');

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  function enforceAdminRole(role: string): boolean {
    if (role !== 'ADMIN' && role !== 'SUPER_ADMIN') {
      setError('Access denied. Admin privileges required.');
      return false;
    }
    return true;
  }

  async function handleEmailLogin(e: FormEvent) {
    e.preventDefault();
    if (!email.trim() || !password) return;

    setError('');
    setLoading(true);
    try {
      const res = await emailLogin(email.trim(), password);
      const { accessToken, refreshToken, user } = res.data;
      if (!enforceAdminRole(user.role)) return;
      login(accessToken, refreshToken, user);
      navigate('/dashboard', { replace: true });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Sign in failed');
    } finally {
      setLoading(false);
    }
  }

  async function handleSendOtp(e: FormEvent) {
    e.preventDefault();
    if (!phone.trim()) return;

    setError('');
    setLoading(true);
    try {
      await sendOtp(phone.trim());
      setPhoneStep('otp');
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to send code');
    } finally {
      setLoading(false);
    }
  }

  async function handleVerifyOtp(e: FormEvent) {
    e.preventDefault();
    if (!code.trim()) return;

    setError('');
    setLoading(true);
    try {
      const res = await verifyOtp(phone.trim(), code.trim());
      const { accessToken, refreshToken, user } = res.data;
      if (!enforceAdminRole(user.role)) return;
      login(accessToken, refreshToken, user);
      navigate('/dashboard', { replace: true });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Verification failed');
    } finally {
      setLoading(false);
    }
  }

  function switchMethod(next: Method) {
    setMethod(next);
    setError('');
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 to-amber-50 flex flex-col">
      <nav className="flex items-center justify-between px-6 py-4 max-w-6xl mx-auto w-full">
        <Link to="/" className="flex items-center gap-2">
          <div className="w-8 h-8 bg-amber-600 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-sm">K</span>
          </div>
          <span className="text-xl font-semibold text-stone-900 tracking-tight">
            Kuwboo
          </span>
        </Link>
      </nav>

      <div className="flex-1 flex items-center justify-center px-6 pb-24">
        <div className="w-full max-w-sm">
          <div className="bg-white rounded-2xl shadow-sm border border-stone-200 p-8">
            <h1 className="text-2xl font-bold text-stone-900 text-center">
              Admin Sign In
            </h1>

            <div
              role="tablist"
              aria-label="Sign-in method"
              className="mt-6 flex p-1 bg-stone-100 rounded-xl"
            >
              <button
                type="button"
                role="tab"
                aria-selected={method === 'email'}
                onClick={() => switchMethod('email')}
                className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
                  method === 'email'
                    ? 'bg-white text-stone-900 shadow-sm'
                    : 'text-stone-500 hover:text-stone-700'
                }`}
              >
                Email
              </button>
              <button
                type="button"
                role="tab"
                aria-selected={method === 'phone'}
                onClick={() => switchMethod('phone')}
                className={`flex-1 py-2 text-sm font-medium rounded-lg transition-colors ${
                  method === 'phone'
                    ? 'bg-white text-stone-900 shadow-sm'
                    : 'text-stone-500 hover:text-stone-700'
                }`}
              >
                Phone
              </button>
            </div>

            <p className="mt-4 text-sm text-stone-500 text-center">
              {method === 'email'
                ? 'Enter your admin email and password'
                : phoneStep === 'phone'
                  ? 'Enter your phone number to receive a verification code'
                  : `We sent a code to ${phone}`}
            </p>

            {error && (
              <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
                {error}
              </div>
            )}

            {method === 'email' ? (
              <form onSubmit={handleEmailLogin} className="mt-6 space-y-4">
                <div>
                  <label
                    htmlFor="email"
                    className="block text-sm font-medium text-stone-700 mb-1.5"
                  >
                    Email
                  </label>
                  <input
                    id="email"
                    type="email"
                    autoComplete="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="you@example.com"
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-stone-900 placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-shadow"
                    autoFocus
                    required
                  />
                </div>
                <div>
                  <div className="flex items-center justify-between mb-1.5">
                    <label
                      htmlFor="password"
                      className="block text-sm font-medium text-stone-700"
                    >
                      Password
                    </label>
                    <Link
                      to="/forgot-password"
                      className="text-xs text-amber-700 hover:text-amber-800 font-medium"
                    >
                      Forgot password?
                    </Link>
                  </div>
                  <PasswordInput
                    id="password"
                    autoComplete="current-password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    minLength={8}
                  />
                </div>
                <button
                  type="submit"
                  disabled={loading || !email.trim() || !password}
                  className="w-full py-2.5 bg-amber-600 text-white rounded-xl text-sm font-medium hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {loading ? 'Signing in...' : 'Sign In'}
                </button>
              </form>
            ) : phoneStep === 'phone' ? (
              <form onSubmit={handleSendOtp} className="mt-6 space-y-4">
                <div>
                  <label
                    htmlFor="phone"
                    className="block text-sm font-medium text-stone-700 mb-1.5"
                  >
                    Phone Number
                  </label>
                  <input
                    id="phone"
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+44 7700 900000"
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-stone-900 placeholder:text-stone-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-shadow"
                    autoFocus
                  />
                </div>
                <button
                  type="submit"
                  disabled={loading || !phone.trim()}
                  className="w-full py-2.5 bg-amber-600 text-white rounded-xl text-sm font-medium hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {loading ? 'Sending...' : 'Send Verification Code'}
                </button>
              </form>
            ) : (
              <form onSubmit={handleVerifyOtp} className="mt-6 space-y-4">
                <div>
                  <label
                    htmlFor="code"
                    className="block text-sm font-medium text-stone-700 mb-1.5"
                  >
                    Verification Code
                  </label>
                  <input
                    id="code"
                    type="text"
                    inputMode="numeric"
                    value={code}
                    onChange={(e) => setCode(e.target.value)}
                    placeholder="000000"
                    maxLength={6}
                    className="w-full px-4 py-2.5 bg-stone-50 border border-stone-200 rounded-xl text-stone-900 text-center text-xl tracking-[0.3em] placeholder:text-stone-400 placeholder:tracking-[0.3em] focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-shadow"
                    autoFocus
                  />
                </div>
                <button
                  type="submit"
                  disabled={loading || !code.trim()}
                  className="w-full py-2.5 bg-amber-600 text-white rounded-xl text-sm font-medium hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {loading ? 'Verifying...' : 'Sign In'}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setPhoneStep('phone');
                    setCode('');
                    setError('');
                  }}
                  className="w-full py-2 text-sm text-stone-500 hover:text-stone-700 transition-colors"
                >
                  Use a different number
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
