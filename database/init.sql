-- Create database (run manually)
-- CREATE DATABASE media_gallery;

-- Connect to media_gallery
-- \c media_gallery

-- Table for users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for media
CREATE TABLE IF NOT EXISTS media (
    id SERIAL PRIMARY KEY,
    type VARCHAR(10) NOT NULL CHECK (type IN ('photo', 'video', 'gif')),
    url VARCHAR(500) NOT NULL,
    thumbnail VARCHAR(500),
    title VARCHAR(200),
    description TEXT,
    uploaded_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin user (password: admin123)
INSERT INTO users (username, password_hash, role) VALUES
('admin', '$2b$10$YourHashedPasswordHere', 'admin')
ON CONFLICT (username) DO NOTHING;

-- Insert sample media
INSERT INTO media (type, url, thumbnail, title, description) VALUES
('photo', 'https://picsum.photos/800/600', 'https://picsum.photos/200/150', 'Sample Photo 1', 'A beautiful landscape'),
('video', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'https://img.youtube.com/vi/YE7VzlLtp-4/0.jpg', 'Sample Video 1', 'Big Buck Bunny'),
('gif', 'https://media.giphy.com/media/3o7abAHdYvZdBNnGZq/giphy.gif', 'https://media.giphy.com/media/3o7abAHdYvZdBNnGZq/giphy.gif', 'Funny GIF', 'A funny cat gif');