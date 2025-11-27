# MongoDB Setup Guide for Railway

## Option 1: Railway MongoDB (Recommended - Easiest)

### Steps:
1. **Go to your Railway project dashboard**
2. **Click "+ New" → "Database" → "Add MongoDB"**
3. Railway will automatically:
   - Create a MongoDB instance
   - Add `MONGO_URL` environment variable to your backend service
   - Handle all connection details

4. **Redeploy your backend service** (Railway will automatically redeploy when you add the database)

That's it! Your backend will automatically connect to MongoDB using the `MONGO_URL` environment variable.

---

## Option 2: MongoDB Atlas (External)

### Steps:

1. **Create MongoDB Atlas Account**
   - Go to https://www.mongodb.com/cloud/atlas
   - Sign up for a free account

2. **Create a Cluster**
   - Click "Build a Database"
   - Choose the FREE tier (M0)
   - Select your preferred cloud provider and region
   - Click "Create"

3. **Set Up Database Access**
   - Go to "Database Access" in the left sidebar
   - Click "Add New Database User"
   - Choose "Password" authentication
   - Create a username and password (save these!)
   - Set user privileges to "Atlas admin" or "Read and write to any database"
   - Click "Add User"

4. **Configure Network Access**
   - Go to "Network Access" in the left sidebar
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (for Railway) or add Railway's IP ranges
   - Click "Confirm"

5. **Get Connection String**
   - Go to "Database" → "Connect"
   - Choose "Connect your application"
   - Copy the connection string (looks like: `mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`)

6. **Add to Railway**
   - Go to your Railway project
   - Select your backend service
   - Go to "Variables" tab
   - Add a new variable:
     - **Name**: `MONGODB_URI`
     - **Value**: Your MongoDB Atlas connection string (replace `<password>` with your actual password)
   - Example: `mongodb+srv://myuser:mypassword@cluster0.xxxxx.mongodb.net/photox?retryWrites=true&w=majority`

7. **Redeploy** your backend service

---

## Verify Connection

After setup, check your Railway logs. You should see:
```
MongoDB Connected: [hostname]
```

If you see connection errors, check:
- ✅ Environment variable is set correctly (`MONGO_URL` or `MONGODB_URI`)
- ✅ MongoDB instance is running (Railway) or cluster is active (Atlas)
- ✅ Network access is configured (for Atlas)
- ✅ Username/password are correct (for Atlas)

---

## Environment Variables Reference

Your backend expects one of these variables:
- `MONGO_URL` (Railway MongoDB default)
- `MONGODB_URI` (Custom/MongoDB Atlas)

The code will automatically use whichever is available.


