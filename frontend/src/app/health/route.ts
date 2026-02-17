import { NextResponse } from 'next/server';

/**
 * Health check endpoint for Kubernetes liveness probe
 * Returns 200 OK if the Next.js server is running
 *
 * Used by: Kubernetes liveness probe
 * Path: GET /health
 */
export async function GET() {
  return NextResponse.json(
    {
      status: 'healthy',
      service: 'todo-frontend',
      timestamp: new Date().toISOString(),
    },
    { status: 200 }
  );
}
