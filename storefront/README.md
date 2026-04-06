# Minimal Storefront Template

A production-ready Next.js 15 storefront template that connects to Medusa backend. This template uses the latest Next.js App Router, React Server Components, and integrates seamlessly with Medusa for ecommerce functionality.

## Features

- Next.js 15 with App Router
- React 19 with Server Components
- TypeScript for type safety
- Tailwind CSS for styling
- Medusa JS SDK for backend integration
- TanStack Query for data fetching and caching
- ESLint for code quality
- Optimized for performance and SEO

## Prerequisites

Before you begin, ensure you have:

- Node.js 18+ installed
- A Medusa backend running (default: `http://localhost:9000`)
- [Bun](https://bun.sh) package manager (recommended) or npm/yarn/pnpm

## Getting Started

### 1. Install Dependencies

```bash
bun install
# or
npm install
# or
yarn install
# or
pnpm install
```

> **Note:** This project uses Bun for faster installs and builds. If you don't have Bun installed, get it from [bun.sh](https://bun.sh)

### 2. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.local.example .env.local
```

Edit `.env.local` and configure your Medusa backend URL:

```env
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
```

### 3. Start the Development Server

```bash
bun run dev
# or
npm run dev
# or
yarn dev
# or
pnpm dev
```

The storefront will be available at [http://localhost:3000](http://localhost:3000).

## Connecting to Medusa Backend

This template uses the Medusa JS SDK to connect to your Medusa backend. The client is configured in `lib/medusa-client.ts`.

### Setting Up Your Medusa Backend

1. Make sure your Medusa backend is running on port 9000 (or update the `NEXT_PUBLIC_MEDUSA_BACKEND_URL` in `.env.local`)
2. The storefront will automatically connect to the backend using the configured URL
3. CORS must be properly configured in your Medusa backend to allow requests from `http://localhost:3000`

### Using the Medusa Client

The Medusa client is available throughout your application:

```typescript
import { medusaClient } from '@/lib/medusa-client'

// Example: Fetch products
const products = await medusaClient.store.product.list()
```

### Data Fetching with TanStack Query

This template uses TanStack Query for efficient data fetching and caching:

```typescript
'use client'

import { useQuery } from '@tanstack/react-query'
import { medusaClient } from '@/lib/medusa-client'

export function ProductList() {
  const { data, isLoading } = useQuery({
    queryKey: ['products'],
    queryFn: () => medusaClient.store.product.list(),
  })

  if (isLoading) return <div>Loading...</div>

  return (
    <div>
      {data?.products.map(product => (
        <div key={product.id}>{product.title}</div>
      ))}
    </div>
  )
}
```

## Project Structure

```
minimal-storefront/
├── app/                    # Next.js App Router
│   ├── layout.tsx         # Root layout with providers
│   ├── page.tsx           # Homepage
│   ├── providers.tsx      # Client-side providers (TanStack Query)
│   └── globals.css        # Global styles
├── lib/                   # Utility libraries
│   └── medusa-client.ts   # Medusa SDK client configuration
├── next.config.mjs        # Next.js configuration
├── tailwind.config.ts     # Tailwind CSS configuration
├── tsconfig.json          # TypeScript configuration
└── package.json           # Dependencies and scripts
```

## Customization Guide

### Adding New Pages

Create a new folder in the `app` directory:

```typescript
// app/products/page.tsx
export default function ProductsPage() {
  return <div>Products Page</div>
}
```

### Creating Components

Create a `components` directory and add your components:

```typescript
// components/Header.tsx
export function Header() {
  return (
    <header className="bg-white shadow">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Your navigation */}
      </nav>
    </header>
  )
}
```

### Styling with Tailwind CSS

This template uses Tailwind CSS. You can customize the theme in `tailwind.config.ts`:

```typescript
theme: {
  extend: {
    colors: {
      primary: '#your-color',
    },
  },
}
```

### Adding Server Components

By default, components in the App Router are Server Components. Use them for data fetching:

```typescript
// app/products/[id]/page.tsx
import { medusaClient } from '@/lib/medusa-client'

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await medusaClient.store.product.retrieve(params.id)

  return <div>{product.title}</div>
}
```

### Adding Client Components

Add `'use client'` directive for interactive components:

```typescript
'use client'

import { useState } from 'react'

export function AddToCart() {
  const [quantity, setQuantity] = useState(1)
  // Your interactive logic
}
```

## Building for Production

### Build the Application

```bash
bun run build
# or
npm run build
```

### Start the Production Server

```bash
bun run start
# or
npm run start
```

## Scripts

- `bun run dev` - Start development server on port 3000
- `bun run build` - Build for production
- `bun run start` - Start production server
- `bun run type-check` - Run TypeScript type checking
- `bun run lint` - Run ESLint

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXT_PUBLIC_MEDUSA_BACKEND_URL` | Medusa backend URL | `http://localhost:9000` |

## Best Practices

### Server Components First

Start with Server Components by default. Only use Client Components when you need:
- Interactive event handlers (onClick, onChange, etc.)
- React hooks (useState, useEffect, etc.)
- Browser-only APIs

### Data Fetching Patterns

- Use Server Components for initial data fetching
- Use TanStack Query in Client Components for interactive data
- Implement proper loading states with Suspense
- Handle errors gracefully with error boundaries

### Performance Optimization

- Use Next.js Image component for optimized images
- Implement proper caching strategies
- Use dynamic imports for code splitting
- Optimize fonts with next/font

## Deployment

This template can be deployed to:

- **Vercel** (recommended for Next.js)
- **Netlify**
- **AWS**
- **Google Cloud**
- Any platform that supports Node.js

### Deploying to Vercel

1. Push your code to GitHub
2. Import your repository in Vercel
3. Configure environment variables
4. Deploy

## Troubleshooting

### CORS Issues

If you encounter CORS errors, ensure your Medusa backend has the correct CORS configuration:

```javascript
// medusa-config.js
module.exports = {
  projectConfig: {
    store_cors: "http://localhost:3000",
  },
}
```

### Connection Issues

Verify that:
1. Your Medusa backend is running
2. The `NEXT_PUBLIC_MEDUSA_BACKEND_URL` is correctly set
3. Network connectivity between frontend and backend is working

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Medusa Documentation](https://docs.medusajs.com)
- [TanStack Query Documentation](https://tanstack.com/query/latest)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## Support

For issues and questions:
- Check the [Medusa Discord](https://discord.gg/medusajs)
- Visit [Medusa Documentation](https://docs.medusajs.com)
- Review [Next.js Documentation](https://nextjs.org/docs)

## License

MIT
