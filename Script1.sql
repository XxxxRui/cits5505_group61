-- Disable foreign key constraints temporarily
PRAGMA foreign_keys = OFF;

-- Drop existing tables if they exist (in correct order)
DROP TABLE IF EXISTS share;
DROP TABLE IF EXISTS achievement;
DROP TABLE IF EXISTS achievement_type;
DROP TABLE IF EXISTS activity;
DROP TABLE IF EXISTS activity_type;
DROP TABLE IF EXISTS user_relations;
DROP TABLE IF EXISTS user;

-- Create database tables

-- User table
CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(64) UNIQUE,
    email VARCHAR(120) UNIQUE,
    password_hash VARCHAR(128),
    date_registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User relationships table (for follow functionality)
CREATE TABLE user_relations (
    follower_id INTEGER,
    followed_id INTEGER,
    PRIMARY KEY (follower_id, followed_id),
    FOREIGN KEY (follower_id) REFERENCES user(id),
    FOREIGN KEY (followed_id) REFERENCES user(id)
);

-- Activity type table (defines all possible activity types)
CREATE TABLE activity_type (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(64) UNIQUE,
    description TEXT,
    icon VARCHAR(64),
    met_value FLOAT,  -- Metabolic Equivalent value, used for calorie calculation
    category VARCHAR(64)
);

-- Activity table
CREATE TABLE activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    activity_type_id INTEGER,
    duration INTEGER,  -- Duration in minutes
    distance FLOAT,    -- Distance in kilometers
    calories INTEGER,  -- Calories burned
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (activity_type_id) REFERENCES activity_type(id)
);

-- Achievement type table (defines all possible achievements)
CREATE TABLE achievement_type (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(64) UNIQUE,
    description VARCHAR(256),
    icon VARCHAR(64),
    requirement_text VARCHAR(256),
    requirement_value INTEGER,
    category VARCHAR(64)
);

-- User achievement table (records achievements earned by users)
CREATE TABLE achievement (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    achievement_type_id INTEGER,
    date_earned TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (achievement_type_id) REFERENCES achievement_type(id)
);

-- Share table
CREATE TABLE share (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    recipient_id INTEGER,
    content_type VARCHAR(32),  -- activity, achievement, or stats
    content_id INTEGER,
    message TEXT,
    date_shared TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (recipient_id) REFERENCES user(id)
);

-- Add user data
INSERT INTO user (username, email, password_hash) VALUES
('user1', 'user1@example.com', 'pbkdf2:sha256:150000$abcdefgh$123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'),
('user2', 'user2@example.com', 'pbkdf2:sha256:150000$abcdefgh$123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'),
('user3', 'user3@example.com', 'pbkdf2:sha256:150000$abcdefgh$123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'),
('user4', 'user4@example.com', 'pbkdf2:sha256:150000$abcdefgh$123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'),
('user5', 'user5@example.com', 'pbkdf2:sha256:150000$abcdefgh$123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');

-- Add user relationships data
INSERT INTO user_relations (follower_id, followed_id) VALUES
(1, 2), -- user1 follows user2
(1, 3), -- user1 follows user3
(2, 1), -- user2 follows user1
(2, 4), -- user2 follows user4
(3, 1), -- user3 follows user1
(3, 2), -- user3 follows user2
(3, 5); -- user3 follows user5

-- Add activity type data
INSERT INTO activity_type (id, name, description, icon, met_value, category) VALUES
(1, 'Running', 'Running activities, including outdoor runs and treadmill', 'running.png', 8.0, 'Cardio'),
(2, 'Walking', 'Various walking activities', 'walking.png', 3.5, 'Cardio'),
(3, 'Cycling', 'Bicycle riding, both indoor and outdoor', 'cycling.png', 7.0, 'Cardio'),
(4, 'Swimming', 'Swimming activities', 'swimming.png', 6.0, 'Cardio'),
(5, 'Hiking', 'Hiking and mountain climbing activities', 'hiking.png', 5.0, 'Outdoor'),
(6, 'Weight Training', 'Strength training and weightlifting', 'weights.png', 4.0, 'Strength'),
(7, 'Yoga', 'Yoga practice', 'yoga.png', 3.0, 'Flexibility'),
(8, 'HIIT', 'High-Intensity Interval Training', 'hiit.png', 9.0, 'Cardio'),
(9, 'Basketball', 'Basketball sport', 'basketball.png', 7.5, 'Team Sports'),
(10, 'Tennis', 'Tennis sport', 'tennis.png', 7.0, 'Racket Sports');

-- Add activity data with reference to activity type table
INSERT INTO activity (user_id, activity_type_id, duration, distance, calories, notes) VALUES
-- user1's activities
(1, 1, 45, 5.2, 320, 'Morning run'),
(1, 3, 60, 15.0, 450, 'Evening ride'),
(1, 4, 30, 1.5, 250, 'Pool workout'),
-- user2's activities
(2, 2, 50, 4.0, 200, 'Afternoon walk'),
(2, 5, 120, 8.5, 650, 'Weekend hike'),
(2, 1, 35, 4.3, 300, 'Quick run'),
-- user3's activities
(3, 3, 75, 22.5, 600, 'Long distance ride'),
(3, 2, 45, 3.5, 180, 'Park walk'),
-- user4's activities
(4, 4, 45, 2.0, 320, 'Swim training'),
(4, 1, 60, 7.5, 480, 'Training run'),
-- user5's activities
(5, 5, 180, 12.0, 850, 'Mountain hike'),
(5, 3, 55, 16.5, 520, 'Road cycling');

-- Add achievement type data
INSERT INTO achievement_type (id, name, description, icon, requirement_text, requirement_value, category) VALUES
(1, 'First Run', 'Completed your first run', 'run.png', 'Complete a running activity', 1, 'Running'),
(2, 'Marathon Master', 'Ran over 42km in total', 'marathon.png', 'Run a total of at least 42km', 42, 'Running'),
(3, 'Early Bird', 'Completed 5 workouts before 7am', 'bird.png', 'Complete workouts before 7am', 5, 'Consistency'),
(4, 'Weekend Warrior', 'Exercised for 3 weekends in a row', 'warrior.png', 'Exercise on weekends consecutively', 3, 'Consistency'),
(5, 'Cycling Pro', 'Cycled over 100km in total', 'bike.png', 'Cycle a total of at least 100km', 100, 'Cycling'),
(6, 'Swim Champion', 'Swam over 10km in total', 'swim.png', 'Swim a total of at least 10km', 10, 'Swimming'),
(7, 'Mountain Goat', 'Completed 5 mountain hikes', 'mountain.png', 'Complete mountain hiking activities', 5, 'Hiking'),
(8, 'Calorie Crusher', 'Burned over 5000 calories', 'fire.png', 'Burn a total of at least 5000 calories', 5000, 'General'),
(9, 'Dedicated Walker', 'Walked over 50km in total', 'shoes.png', 'Walk a total of at least 50km', 50, 'Walking'),
(10, 'Iron Man', 'Exercised for 30 days in a row', 'ironman.png', 'Exercise daily without missing a day', 30, 'Consistency');

-- Add user achievement data
INSERT INTO achievement (id, user_id, achievement_type_id, date_earned) VALUES
(1, 1, 1, datetime('now', '-20 days')), -- First Run (user1)
(2, 1, 2, datetime('now', '-10 days')), -- Marathon Master (user1)
(3, 2, 3, datetime('now', '-15 days')), -- Early Bird (user2)
(4, 2, 4, datetime('now', '-5 days')),  -- Weekend Warrior (user2)
(5, 3, 5, datetime('now', '-12 days')), -- Cycling Pro (user3)
(6, 4, 6, datetime('now', '-8 days')),  -- Swim Champion (user4)
(7, 5, 7, datetime('now', '-3 days'));  -- Mountain Goat (user5)

-- Add share data
INSERT INTO share (user_id, recipient_id, content_type, content_id, message) VALUES
-- For activities, content_id refers to activity.id
(1, 2, 'activity', 1, 'Check out my running activity!'),
(3, 4, 'activity', 7, 'Long cycling ride today!'),
(5, 3, 'activity', 11, 'Amazing views on this hike!'),
(2, 4, 'activity', 5, 'Great weekend hike'),
(3, 1, 'activity', 8, 'Nice weather for a walk'),
(4, 2, 'activity', 9, 'Pool was empty today'),

-- For achievements, content_id refers to achievement.id (not achievement_type.id)
(2, 1, 'achievement', 3, 'I earned the Early Bird achievement!'),
(4, 5, 'achievement', 6, 'Finally got my swimming achievement!'),
(1, 3, 'achievement', 2, 'Completed my first marathon!'),
(5, 1, 'achievement', 7, 'Love hiking in the mountains!');

-- Enable foreign key constraints again
PRAGMA foreign_keys = ON;

-- Verify all tables were created and populated
SELECT 'user' as table_name, COUNT(*) as record_count FROM user
UNION ALL
SELECT 'user_relations', COUNT(*) FROM user_relations
UNION ALL
SELECT 'activity_type', COUNT(*) FROM activity_type
UNION ALL
SELECT 'activity', COUNT(*) FROM activity
UNION ALL
SELECT 'achievement_type', COUNT(*) FROM achievement_type
UNION ALL
SELECT 'achievement', COUNT(*) FROM achievement
UNION ALL
SELECT 'share', COUNT(*) FROM share;