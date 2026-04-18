import { useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router';
import { emailForgotPassword } from '../api/client';

export function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [devCode, setDevCode] = useState<string | null>(null);
  const navigate = useNavigate();

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!email.trim()) return;

    setError('');
    setLoading(true);
    try {
      const res = await emailForgotPassword(email.trim());
      const code = res.data?.devCode;
      if (code) {
        setDevCode(code);
        return;
      }
      navigate(`/reset-password?email=${encodeURIComponent(email.trim())}`, {
        replace: false,
      });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to send code');
    } finally {
      setLoading(false);
    }
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
              Reset Password
            </h1>
            <p className="mt-2 text-sm text-stone-500 text-center">
              {devCode
                ? 'Code generated in dev mode. Use it on the next screen.'
                : 'Enter your admin email — we will send a reset code.'}
            </p>

            {error && (
              <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
                {error}
              </div>
            )}

            {devCode ? (
              <div className="mt-6 space-y-4">
                <div className="p-4 bg-amber-50 border border-amber-200 rounded-xl">
                  <div className="text-xs font-medium text-amber-800 uppercase tracking-wide">
                    Dev code
                  </div>
                  <div className="mt-1 text-2xl font-mono font-bold text-amber-900 tracking-[0.3em]">
                    {devCode}
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() =>
                    navigate(
                      `/reset-password?email=${encodeURIComponent(email.trim())}`,
                    )
                  }
                  className="w-full py-2.5 bg-amber-600 text-white rounded-xl text-sm font-medium hover:bg-amber-700 transition-colors"
                >
                  Continue
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="mt-6 space-y-4">
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
                <button
                  type="submit"
                  disabled={loading || !email.trim()}
                  className="w-full py-2.5 bg-amber-600 text-white rounded-xl text-sm font-medium hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {loading ? 'Sending...' : 'Send Reset Code'}
                </button>
                <Link
                  to="/login"
                  className="block w-full py-2 text-sm text-stone-500 hover:text-stone-700 transition-colors text-center"
                >
                  Back to sign in
                </Link>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
