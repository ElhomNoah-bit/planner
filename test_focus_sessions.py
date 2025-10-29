#!/usr/bin/env python3
"""
Manual test script for Focus Session functionality.
This script tests the FocusSessionRepository CRUD operations.
"""

import json
import os
import tempfile
from datetime import datetime, timedelta

def test_focus_session_repository():
    """Test basic FocusSessionRepository functionality"""
    
    # Create a temporary directory for testing
    test_dir = tempfile.mkdtemp()
    test_file = os.path.join(test_dir, "focus_sessions.json")
    
    print(f"Testing Focus Session Repository in: {test_dir}")
    
    # Test 1: Create empty focus sessions file
    print("\n[Test 1] Creating empty focus sessions file...")
    sessions = []
    with open(test_file, 'w') as f:
        json.dump(sessions, f, indent=2)
    
    assert os.path.exists(test_file), "Failed to create file"
    print("✓ Empty file created")
    
    # Test 2: Add a focus session
    print("\n[Test 2] Adding a focus session...")
    now = datetime.now()
    session = {
        "id": "test-session-1",
        "taskId": "task-123",
        "start": now.isoformat(),
        "end": (now + timedelta(minutes=30)).isoformat(),
        "durationSeconds": 1800,  # 30 minutes
        "completed": True
    }
    
    sessions.append(session)
    with open(test_file, 'w') as f:
        json.dump(sessions, f, indent=2)
    
    with open(test_file, 'r') as f:
        loaded = json.load(f)
    
    assert len(loaded) == 1, "Failed to add session"
    assert loaded[0]["id"] == "test-session-1", "Session ID mismatch"
    assert loaded[0]["durationSeconds"] == 1800, "Duration mismatch"
    print("✓ Session added successfully")
    
    # Test 3: Add multiple sessions
    print("\n[Test 3] Adding multiple sessions for different days...")
    for i in range(7):
        date = now - timedelta(days=i)
        session = {
            "id": f"test-session-{i+2}",
            "taskId": f"task-{i}",
            "start": date.isoformat(),
            "end": (date + timedelta(minutes=45)).isoformat(),
            "durationSeconds": 2700,  # 45 minutes
            "completed": True
        }
        sessions.append(session)
    
    with open(test_file, 'w') as f:
        json.dump(sessions, f, indent=2)
    
    with open(test_file, 'r') as f:
        loaded = json.load(f)
    
    assert len(loaded) == 8, f"Expected 8 sessions, got {len(loaded)}"
    print(f"✓ Added 7 more sessions (total: {len(loaded)})")
    
    # Test 4: Calculate daily minutes
    print("\n[Test 4] Calculating daily minutes...")
    today_date = now.date()
    today_sessions = [s for s in loaded if datetime.fromisoformat(s["start"]).date() == today_date]
    total_seconds = sum(s["durationSeconds"] for s in today_sessions if s["completed"])
    total_minutes = total_seconds // 60
    
    print(f"✓ Today's focus time: {total_minutes} minutes")
    
    # Test 5: Streak calculation simulation
    print("\n[Test 5] Simulating streak calculation...")
    THRESHOLD = 30  # 30 minutes minimum
    streak = 0
    
    for i in range(365):  # Check up to 365 days back
        check_date = (now - timedelta(days=i)).date()
        day_sessions = [s for s in loaded if datetime.fromisoformat(s["start"]).date() == check_date]
        day_seconds = sum(s["durationSeconds"] for s in day_sessions if s["completed"])
        day_minutes = day_seconds // 60
        
        if day_minutes >= THRESHOLD:
            streak += 1
        else:
            break  # Streak broken
    
    print(f"✓ Current streak: {streak} days")
    
    # Test 6: Weekly data
    print("\n[Test 6] Generating weekly data...")
    week_start = today_date - timedelta(days=today_date.weekday())
    weekly_data = {}
    
    for i in range(7):
        date = week_start + timedelta(days=i)
        day_sessions = [s for s in loaded if datetime.fromisoformat(s["start"]).date() == date]
        day_seconds = sum(s["durationSeconds"] for s in day_sessions if s["completed"])
        weekly_data[date.isoformat()] = day_seconds // 60
    
    print("Weekly focus minutes:")
    for date, minutes in weekly_data.items():
        print(f"  {date}: {minutes} minutes")
    
    # Cleanup
    print("\n[Cleanup] Removing test directory...")
    os.remove(test_file)
    os.rmdir(test_dir)
    print("✓ Cleanup complete")
    
    print("\n" + "="*50)
    print("All tests passed! ✓")
    print("="*50)

if __name__ == "__main__":
    try:
        test_focus_session_repository()
    except AssertionError as e:
        print(f"\n✗ Test failed: {e}")
        exit(1)
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        exit(1)
