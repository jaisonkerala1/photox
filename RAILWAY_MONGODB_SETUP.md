# How to Add MongoDB Environment Variable in Railway

## Step-by-Step Instructions

### Method 1: Using Railway's Automatic Variable Reference (Recommended)

1. **Go to your Railway project dashboard**
   - Navigate to https://railway.app
   - Select your project

2. **Select your MongoDB service**
   - Click on the MongoDB service (the one showing `photox.railway.internal`)

3. **Copy the Connection String**
   - In the MongoDB service, go to the **"Variables"** tab
   - Look for `MONGO_URL` or `MONGO_URL_INTERNAL`
   - Copy the value (it should look like: `mongodb://mongo:27017` or `mongodb+srv://...`)

4. **Add to Backend Service**
   - Go back to your project dashboard
   - Click on your **backend service** (the Node.js one)
   - Go to the **"Variables"** tab
   - Click **"+ New Variable"**
   - Add:
     - **Name**: `MONGO_URL`
     - **Value**: Paste the connection string from step 3
   - Click **"Add"**

5. **Redeploy** (Railway will auto-redeploy when you add variables)

---

### Method 2: Reference Variable from MongoDB Service

Railway allows you to reference variables from other services:

1. **In your Backend Service → Variables tab**
2. **Click "+ New Variable"**
3. **Instead of typing a value, click "Reference"**
4. **Select your MongoDB service**
5. **Select `MONGO_URL` or `MONGO_URL_INTERNAL`**
6. **Save**

This creates a reference that automatically updates if the MongoDB connection changes.

---

### Method 3: Manual Connection String

If you need to manually set it:

1. **In your Backend Service → Variables tab**
2. **Click "+ New Variable"**
3. **Add:**
   - **Name**: `MONGO_URL`
   - **Value**: `mongodb://mongo:27017/photox` (for internal Railway connection)
   - OR: `mongodb+srv://username:password@cluster.mongodb.net/photox` (for MongoDB Atlas)

---

## Verify Connection

After adding the variable:

1. **Check Railway Logs**
   - Go to your backend service
   - Click on **"Deployments"** → Latest deployment → **"View Logs"**
   - Look for: `✅ MongoDB Connected: [hostname]`

2. **If you see connection errors:**
   - ✅ Check the variable name is exactly `MONGO_URL` (case-sensitive)
   - ✅ Verify the MongoDB service is running
   - ✅ Check the connection string format is correct

---

## Railway MongoDB Connection String Format

Railway MongoDB typically provides:
- **Internal**: `mongodb://mongo:27017` (for service-to-service)
- **Public**: `mongodb+srv://...` (for external access)

Your backend code supports both `MONGO_URL` and `MONGO_URL_INTERNAL`, so use whichever Railway provides.

---

## Quick Checklist

- [ ] MongoDB service is running in Railway
- [ ] `MONGO_URL` variable added to backend service
- [ ] Backend service redeployed
- [ ] Logs show "MongoDB Connected" message


