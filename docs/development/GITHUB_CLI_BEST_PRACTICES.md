# GitHub CLI Best Practices for AI Agents

## PR Creation Best Practices

### Common Issues and Solutions

#### Issue 1: Parentheses Escaping in PR Body
**Problem**: zsh treats parentheses as special characters for command substitution
```bash
# ❌ This fails
gh pr create --title "title" --body "Body with (parentheses)"
```

**Solutions**:
```bash
# ✅ Option A: Use single quotes
gh pr create --title "title" --body 'Body with (parentheses)'

# ✅ Option B: Escape parentheses
gh pr create --title "title" --body "Body with \(parentheses\)"

# ✅ Option C: Use file (recommended for complex bodies)
echo "Body with (parentheses)" > pr_body.md
gh pr create --title "title" --body-file pr_body.md

# ✅ Option D: Use our script (recommended)
./scripts/create-pr.sh "title" "Body with (parentheses)"
```

#### Issue 2: Branch Not Pushed Before PR Creation
**Problem**: GitHub CLI prompts for confirmation when branch doesn't exist remotely

**Solutions**:
```bash
# ✅ Always push first (recommended)
git push origin feature/branch-name
gh pr create --title "title" --body "body"

# ✅ Use our script (handles this automatically)
./scripts/create-pr.sh "title" "body"
```

### Recommended Workflow

#### For Simple PRs
```bash
# 1. Ensure branch is pushed
git push origin feature/branch-name

# 2. Create PR with single quotes
gh pr create --title "feat: Add new feature" --body 'This PR adds...'
```

#### For Complex PRs
```bash
# 1. Create body file
cat > pr_body.md << 'EOF'
## 🎯 Feature Description

This PR adds comprehensive functionality including:
- Feature A (with parentheses)
- Feature B (with special chars)
- Feature C

### Testing
All tests pass (100% success rate)
EOF

# 2. Use our script
./scripts/create-pr.sh "feat: Add comprehensive feature" pr_body.md
```

### Available Scripts

#### `scripts/create-pr.sh`
- Handles both simple and complex PR creation
- Automatic branch pushing
- Supports both text and file inputs
- Handles special characters properly
- **Recommended for all PRs**

### Best Practices Summary

1. **Always push branch first** - Avoid interactive prompts
2. **Use single quotes for simple bodies** - Avoid escaping issues
3. **Use files for complex bodies** - Handle special characters properly
4. **Use our script** - Automate common workflows
5. **Test commands** - Verify syntax before running

### Common Patterns

#### Standard PR Creation
```bash
./scripts/create-pr.sh "feat: Add new feature" "This PR adds..."
```

#### PR with Complex Body
```bash
# Create body file
cat > pr_body.md << 'EOF'
## 🎯 Feature Description

This PR adds comprehensive functionality including:
- Feature A (with parentheses)
- Feature B (with special chars)

### Testing
All tests pass (100% success rate)
EOF

# Create PR
./scripts/create-pr.sh "feat: Add comprehensive feature" pr_body.md
```

#### Force Push (when needed)
```bash
git push origin feature/branch-name --force
./scripts/create-pr.sh "feat: Update feature" "Updated implementation"
``` 