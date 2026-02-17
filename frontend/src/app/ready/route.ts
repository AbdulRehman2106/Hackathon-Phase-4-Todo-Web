import { NextResponse } from 'next/server';

/**
 * Readiness check endpoint for Kubernetes readiness probe
 * Returns 200 OK if the application is ready to serve traffic
 * Checks if backend API is reachable
 *
 * Used by: Kubernetes readiness probe
 * Path: GET /ready
 */
export async function GET() {
  try {
    // Check if backend is reachable
    const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

    // Simple connectivity check with timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3000);

    const response = await fetch(`${backendUrl}/health`, {
      signal: controller.signal,
      cache: 'no-store',
    });

    clearTimeout(timeoutId);

    if (response.ok) {
      return NextResponse.json(
        {
          status: 'ready',
          service: 'todo-frontend',
          backend: 'reachable',
          timestamp: new Date().toISOString(),
        },
        { status: 200 }
      );
    } else {
      return NextResponse.json(
        {
          status: 'not_ready',
          service: 'todo-frontend',
          backend: 'unreachable',
          error: `Backend returned ${response.status}`,
          timestamp: new Date().toISOString(),
        },
        { status: 503 }
      );
    }
  } catch (error) {
    return NextResponse.json(
      {
        status: 'not_ready',
        service: 'todo-frontend',
        backend: 'unreachable',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      },
      { status: 503 }
    );
  }
}
