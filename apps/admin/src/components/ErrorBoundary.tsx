import { Component, type ReactNode, type ErrorInfo } from 'react';
import { useLocation } from 'react-router';

interface Props {
  children: ReactNode;
  resetKey?: string | number;
}

interface State {
  error: Error | null;
}

class ErrorBoundaryInner extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidUpdate(prevProps: Props) {
    if (
      this.state.error &&
      prevProps.resetKey !== this.props.resetKey
    ) {
      this.setState({ error: null });
    }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('[ErrorBoundary]', error, info.componentStack);
  }

  handleReload = () => {
    this.setState({ error: null });
  };

  render() {
    if (this.state.error) {
      return (
        <div className="flex flex-col items-center justify-center py-16 px-6">
          <div className="max-w-md w-full bg-white rounded-xl border border-red-200 shadow-sm p-6">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-red-50 rounded-full flex items-center justify-center text-red-600 text-xl">
                !
              </div>
              <h1 className="text-lg font-semibold text-stone-900">
                Something went wrong
              </h1>
            </div>
            <p className="mt-3 text-sm text-stone-600">
              This page hit an unexpected error. The rest of the admin
              dashboard is still available in the sidebar.
            </p>
            <pre className="mt-3 p-3 text-xs bg-stone-50 border border-stone-100 rounded-lg text-stone-700 overflow-auto max-h-40">
              {this.state.error.message}
            </pre>
            <div className="mt-4 flex gap-2">
              <button
                onClick={this.handleReload}
                className="px-3 py-1.5 text-sm font-medium text-white bg-amber-600 rounded-lg hover:bg-amber-700"
              >
                Try again
              </button>
              <button
                onClick={() => window.location.reload()}
                className="px-3 py-1.5 text-sm font-medium text-stone-600 bg-stone-100 rounded-lg hover:bg-stone-200"
              >
                Reload page
              </button>
            </div>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

export function ErrorBoundary({ children }: { children: ReactNode }) {
  const location = useLocation();
  return (
    <ErrorBoundaryInner resetKey={location.pathname}>
      {children}
    </ErrorBoundaryInner>
  );
}
