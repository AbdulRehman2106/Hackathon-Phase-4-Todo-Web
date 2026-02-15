# Vercel Deployment Guide

## 🚀 Quick Deploy to Vercel

### Prerequisites
- GitHub account
- Vercel account (free tier works)
- Backend deployed at: https://abdul18-ai-todo-chatbot.hf.space

---

## 📋 Step-by-Step Deployment

### Method 1: Deploy via Vercel Dashboard (Recommended)

1. **Go to Vercel**
   - Visit: https://vercel.com
   - Click "Login" or "Sign Up"
   - Connect your GitHub account

2. **Import Project**
   - Click "Add New..." → "Project"
   - Select your GitHub repository: `Hackathon-Phase-3-AI-Todo-Chatbot`
   - Click "Import"

3. **Configure Project**
   - **Framework Preset:** Next.js (auto-detected)
   - **Root Directory:** `frontend`
   - **Build Command:** `npm run build` (auto-filled)
   - **Output Directory:** `.next` (auto-filled)
   - **Install Command:** `npm install` (auto-filled)

4. **Environment Variables**
   Add these in the "Environment Variables" section:

   ```
   NEXT_PUBLIC_API_URL=https://abdul18-ai-todo-chatbot.hf.space
   NEXT_PUBLIC_APP_NAME=AI Todo Chatbot
   ```

5. **Deploy**
   - Click "Deploy"
   - Wait 2-3 minutes for build to complete
   - Your app will be live at: `https://your-project-name.vercel.app`

---

### Method 2: Deploy via Vercel CLI

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy from Frontend Directory**
   ```bash
   cd frontend
   vercel
   ```

4. **Follow Prompts**
   - Set up and deploy? Yes
   - Which scope? Select your account
   - Link to existing project? No
   - Project name? (press enter for default)
   - Directory? `./` (current directory)
   - Override settings? No

5. **Set Environment Variables**
   ```bash
   vercel env add NEXT_PUBLIC_API_URL
   # Enter: https://abdul18-ai-todo-chatbot.hf.space

   vercel env add NEXT_PUBLIC_APP_NAME
   # Enter: AI Todo Chatbot
   ```

6. **Deploy to Production**
   ```bash
   vercel --prod
   ```

---

## 🔧 Configuration Files

### vercel.json
Located at: `frontend/vercel.json`
- Configures build settings
- Sets environment variables
- Adds security headers

### .env.production
Located at: `frontend/.env.production`
- Production environment variables
- Backend API URL
- App name

### next.config.js
Located at: `frontend/next.config.js`
- Next.js configuration
- API rewrites for CORS
- Standalone output mode

---

## ✅ Post-Deployment Checklist

After deployment, verify:

- [ ] App loads successfully
- [ ] Dark mode toggle works
- [ ] Can create account (signup)
- [ ] Can login
- [ ] Can create tasks
- [ ] Can view tasks
- [ ] AI chatbot responds
- [ ] All 10 UI features work
- [ ] No console errors
- [ ] API calls reach backend

---

## 🔍 Testing Your Deployment

1. **Open Your Vercel URL**
   - Example: `https://your-project-name.vercel.app`

2. **Test Authentication**
   - Create a new account
   - Login with credentials

3. **Test Task Management**
   - Create a task
   - Update a task
   - Delete a task

4. **Test AI Chatbot**
   - Open chat interface
   - Send message: "Create a task to buy groceries"
   - Verify task is created

5. **Test UI Features**
   - Toggle dark mode
   - Try drag & drop
   - Use filters
   - View calendar
   - Check analytics

---

## 🐛 Troubleshooting

### Issue: API calls failing
**Solution:** Check environment variables in Vercel dashboard
- Go to Project Settings → Environment Variables
- Verify `NEXT_PUBLIC_API_URL` is correct

### Issue: Build fails
**Solution:** Check build logs in Vercel dashboard
- Common fixes:
  - Clear build cache and redeploy
  - Check package.json dependencies
  - Verify Node.js version compatibility

### Issue: 404 errors
**Solution:** Check Next.js routing
- Verify all pages are in `frontend/src/app/` directory
- Check for typos in route names

### Issue: CORS errors
**Solution:** Backend CORS configuration
- Verify backend allows your Vercel domain
- Check `CORS_ORIGINS` in backend `.env`

---

## 🔄 Redeployment

### Automatic Redeployment
- Every push to `main` branch triggers automatic deployment
- Every push to feature branches creates preview deployments

### Manual Redeployment
1. Go to Vercel dashboard
2. Select your project
3. Click "Deployments" tab
4. Click "Redeploy" on latest deployment

---

## 📊 Monitoring

### Vercel Analytics
- View in Vercel dashboard
- Real-time visitor stats
- Performance metrics

### Error Tracking
- Check "Functions" tab for API errors
- View build logs for deployment issues

---

## 🎯 Production URLs

- **Frontend:** `https://your-project-name.vercel.app`
- **Backend:** `https://abdul18-ai-todo-chatbot.hf.space`
- **API Docs:** `https://abdul18-ai-todo-chatbot.hf.space/docs`

---

## 🔐 Security Notes

- Environment variables are encrypted by Vercel
- HTTPS enabled by default
- Security headers configured in `vercel.json`
- API keys never exposed to client

---

## 📝 Custom Domain (Optional)

1. Go to Project Settings → Domains
2. Click "Add Domain"
3. Enter your domain name
4. Follow DNS configuration instructions
5. Wait for DNS propagation (up to 48 hours)

---

## 🎉 Success!

Your AI Todo Chatbot is now live on Vercel! 🚀

Share your deployment URL and start using your application!
