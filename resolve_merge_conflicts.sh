#!/bin/bash

# Merge Conflict Resolution Script for Planner Repository
# This script helps resolve merge conflicts in all open pull requests
# by merging main into feature branches, preferring feature branch changes

set -e  # Exit on error

# Colors for output
RED='\033[0:31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Function to resolve conflicts by preferring feature branch (ours)
auto_resolve_conflicts() {
    local conflicted_files=$(git diff --name-only --diff-filter=U)
    
    if [ -z "$conflicted_files" ]; then
        print_info "No conflicts to resolve"
        return 0
    fi
    
    print_warning "Found conflicted files:"
    echo "$conflicted_files"
    
    echo ""
    read -p "Attempt automatic resolution by preferring feature branch changes? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for file in $conflicted_files; do
            print_info "Resolving $file (keeping feature branch version)"
            git checkout --ours "$file"
            git add "$file"
        done
        print_info "Conflicts auto-resolved"
        return 0
    else
        print_info "Skipping automatic resolution. Please resolve manually."
        return 1
    fi
}

# Function to merge main into a feature branch
merge_feature_branch() {
    local branch_name=$1
    local pr_number=$2
    local feature_description=$3
    
    print_info "========================================="
    print_info "Processing PR #$pr_number: $feature_description"
    print_info "Branch: $branch_name"
    print_info "========================================="
    
    # Check if branch exists remotely
    if ! git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
        print_error "Branch $branch_name does not exist on origin"
        return 1
    fi
    
    # Fetch latest changes
    print_info "Fetching latest changes..."
    git fetch origin
    
    # Checkout the branch
    print_info "Checking out $branch_name..."
    git checkout "$branch_name"
    
    # Pull latest changes from feature branch
    print_info "Pulling latest changes from feature branch..."
    git pull origin "$branch_name"
    
    # Attempt to merge main
    print_info "Merging origin/main into $branch_name..."
    if git merge origin/main --no-edit -m "Merge main into $feature_description (prefer feature branch changes)"; then
        print_info "Merge successful without conflicts!"
    else
        print_warning "Merge conflicts detected"
        
        # Attempt automatic resolution
        if auto_resolve_conflicts; then
            git commit -m "Merge main into $feature_description (prefer feature branch changes)"
            print_info "Merge committed successfully"
        else
            print_error "Please resolve conflicts manually, then run:"
            print_error "  git add <resolved-files>"
            print_error "  git commit"
            print_error "  git push origin $branch_name"
            return 1
        fi
    fi
    
    # Push changes
    read -p "Push changes to origin/$branch_name? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Pushing changes to origin/$branch_name..."
        git push origin "$branch_name"
        print_info "Successfully updated PR #$pr_number"
    else
        print_warning "Skipped pushing. You can push manually with:"
        print_warning "  git push origin $branch_name"
    fi
    
    echo ""
    return 0
}

# Main script
main() {
    print_info "Planner Repository - Merge Conflict Resolution Script"
    echo ""
    
    # Check if in git repo
    check_git_repo
    
    # Store original branch
    original_branch=$(git branch --show-current)
    print_info "Current branch: $original_branch"
    
    # Define the PRs to process
    declare -A prs
    prs[4]="copilot/add-focus-session-module|Focus session tracking with streak gamification"
    prs[5]="copilot/add-deadline-stress-display|Deadline stress indicator with visual emphasis"
    prs[6]="copilot/add-pdf-exporter-functionality|PDF export for week and month schedules"
    prs[7]="copilot/add-pomodoro-focus-timer|Pomodoro focus timer with auto-transitions"
    
    # Ask which PRs to process
    echo "Which PRs would you like to resolve?"
    echo "1) PR #4: Focus session tracking"
    echo "2) PR #5: Deadline stress indicator"
    echo "3) PR #6: PDF export"
    echo "4) PR #7: Pomodoro timer"
    echo "5) All PRs"
    echo "6) Custom order"
    read -p "Enter choice (1-6): " choice
    
    case $choice in
        1)
            IFS='|' read -r branch desc <<< "${prs[4]}"
            merge_feature_branch "$branch" 4 "$desc"
            ;;
        2)
            IFS='|' read -r branch desc <<< "${prs[5]}"
            merge_feature_branch "$branch" 5 "$desc"
            ;;
        3)
            IFS='|' read -r branch desc <<< "${prs[6]}"
            merge_feature_branch "$branch" 6 "$desc"
            ;;
        4)
            IFS='|' read -r branch desc <<< "${prs[7]}"
            merge_feature_branch "$branch" 7 "$desc"
            ;;
        5)
            # Process all PRs in order
            for pr_num in 4 5 6 7; do
                IFS='|' read -r branch desc <<< "${prs[$pr_num]}"
                if ! merge_feature_branch "$branch" "$pr_num" "$desc"; then
                    print_error "Failed to process PR #$pr_num"
                    read -p "Continue with next PR? (y/n) " -n 1 -r
                    echo ""
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        break
                    fi
                fi
                echo ""
            done
            ;;
        6)
            read -p "Enter PR numbers to process (e.g., 4 6 7): " pr_list
            for pr_num in $pr_list; do
                if [[ -n "${prs[$pr_num]}" ]]; then
                    IFS='|' read -r branch desc <<< "${prs[$pr_num]}"
                    merge_feature_branch "$branch" "$pr_num" "$desc"
                    echo ""
                else
                    print_error "Unknown PR number: $pr_num"
                fi
            done
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Return to original branch
    print_info "Returning to original branch: $original_branch"
    git checkout "$original_branch"
    
    print_info "========================================="
    print_info "Merge conflict resolution complete!"
    print_info "========================================="
    echo ""
    print_info "Next steps:"
    print_info "1. Check each PR on GitHub to verify it's now mergeable"
    print_info "2. Review the changes to ensure everything looks correct"
    print_info "3. Test the features locally if needed"
    print_info "4. Merge the PRs when ready"
}

# Run main function
main
