# Push Project to GitHub

## Commands to Run

Run these commands in your terminal:

```bash
cd /Users/user/Desktop/cody-schoolMangement

# 1. Initialize git (if not already done)
git init

# 2. Add remote repository
git remote add origin git@github.com:DianaAlghazawi/cody-schoolMangement.git
# OR if remote already exists:
git remote set-url origin git@github.com:DianaAlghazawi/cody-schoolMangement.git

# 3. Configure git user (if not already set)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# 4. Stage all files
git add .

# 5. Commit changes
git commit -m "Initial commit: ClassHub School Management App - Production ready for Google Play Console"

# 6. Set main branch
git branch -M main

# 7. Push to GitHub
git push -u origin main
```

## Important Notes

### ✅ Files Already Excluded (via .gitignore):
- `android/key.properties` - Keystore credentials
- `*.jks` / `*.keystore` - Keystore files
- `android/local.properties` - Local SDK paths
- `build/` - Build outputs
- `.dart_tool/` - Dart tooling
- `.gradle/` - Gradle cache

### ⚠️ Before Pushing:
1. **Verify sensitive files are NOT staged:**
   ```bash
   git status
   ```
   Make sure you don't see:
   - `key.properties`
   - `*.jks` or `*.keystore` files
   - `local.properties`

2. **If you see sensitive files, remove them:**
   ```bash
   git reset HEAD android/key.properties
   git reset HEAD android/*.jks
   ```

## Troubleshooting

### If push fails with authentication error:
```bash
# Use HTTPS instead of SSH:
git remote set-url origin https://github.com/DianaAlghazawi/cody-schoolMangement.git
git push -u origin main
```

### If repository doesn't exist on GitHub:
1. Go to https://github.com/DianaAlghazawi
2. Click "New repository"
3. Name it: `cody-schoolMangement`
4. Don't initialize with README (since you're pushing existing code)
5. Then run the push command

### If you need to force push (be careful!):
```bash
git push -u origin main --force
```

## Verify After Push

Check your repository:
https://github.com/DianaAlghazawi/cody-schoolMangement

Make sure sensitive files are NOT visible in the repository!

