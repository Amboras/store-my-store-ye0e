#!/bin/bash
set -e

echo "🚀 Starting Amboras Dev Workspace..."

# Environment variables (set by orchestrator)
STORE_ID=${STORE_ID:-"unknown"}
DATABASE_URL=${DATABASE_URL:-""}
WORKSPACE_PATH=${WORKSPACE_PATH:-"/workspace"}

echo "📦 Store ID: $STORE_ID"
echo "📁 Workspace: $WORKSPACE_PATH"

# If workspace has user code, use it; otherwise use template
if [ -d "$WORKSPACE_PATH/backend" ]; then
  echo "✅ Using user's code from $WORKSPACE_PATH"

  # Symlink node_modules from image (avoid re-install)
  if [ ! -L "$WORKSPACE_PATH/backend/node_modules" ]; then
    ln -sf /app/backend/node_modules $WORKSPACE_PATH/backend/node_modules
  fi

  if [ ! -L "$WORKSPACE_PATH/storefront/node_modules" ]; then
    ln -sf /app/storefront/node_modules $WORKSPACE_PATH/storefront/node_modules
  fi

  # Use workspace code
  BACKEND_DIR="$WORKSPACE_PATH/backend"
  STOREFRONT_DIR="$WORKSPACE_PATH/storefront"
else
  echo "✅ Using template code from /app"

  # Use template code (first time)
  BACKEND_DIR="/app/backend"
  STOREFRONT_DIR="/app/storefront"
fi

# Start backend in background (dev mode for hot reload)
echo "🔧 Starting Medusa backend..."
cd "$BACKEND_DIR"
npm run dev > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started (PID: $BACKEND_PID)"

# Wait for backend to be ready
echo "⏳ Waiting for backend..."
for i in {1..60}; do
  if curl -f http://localhost:9000/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "❌ Backend failed to start in 60 seconds"
    cat /tmp/backend.log
    exit 1
  fi
  sleep 1
done

# Start storefront in background (dev mode for hot reload)
echo "🎨 Starting Next.js storefront..."
cd "$STOREFRONT_DIR"
npm run dev -- -p 3000 > /tmp/storefront.log 2>&1 &
STOREFRONT_PID=$!
echo "✅ Storefront started (PID: $STOREFRONT_PID)"

# Wait for storefront to be ready
echo "⏳ Waiting for storefront..."
for i in {1..60}; do
  if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Storefront is healthy"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "❌ Storefront failed to start in 60 seconds"
    cat /tmp/storefront.log
    exit 1
  fi
  sleep 1
done

echo "🎉 Workspace ready!"
echo "   Backend: http://localhost:9000"
echo "   Storefront: http://localhost:3000"
echo "   Admin: http://localhost:9000/app"

# Keep container alive and forward signals
trap "kill $BACKEND_PID $STOREFRONT_PID 2>/dev/null; wait" SIGTERM SIGINT EXIT

# Wait for either process to exit
wait -n $BACKEND_PID $STOREFRONT_PID

# If we get here, one of the processes died
exit_code=$?
echo "❌ A service has stopped unexpectedly (exit code: $exit_code)"
echo "Backend log:"
cat /tmp/backend.log
echo ""
echo "Storefront log:"
cat /tmp/storefront.log
exit $exit_code
