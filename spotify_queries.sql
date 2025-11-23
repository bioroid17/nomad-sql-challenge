-- Part 1: Basic JOINs
-- Challenge 1. List all album names with their artist names (use appropriate through table)
SELECT
  albums.name AS album_name,
  artists.name AS artist_name
FROM
  albums
  JOIN r_albums_artists raa ON albums.id = raa.album_id
  JOIN artists ON artists.id = raa.artist_id
ORDER BY
  album_name
LIMIT
  100;

-- Challenge 2. Show all tracks with their album names
SELECT
  tracks.name AS track_name,
  albums.name AS album_name
FROM
  albums
  JOIN r_albums_tracks rat ON albums.id = rat.album_id
  JOIN tracks ON tracks.id = rat.track_id
ORDER BY
  track_name
LIMIT
  100;

-- Challenge 3. Display artists with their genres
SELECT
  artists.name AS artist_name,
  genres.id AS genre_id
FROM
  artists
  JOIN r_artist_genre r ON artists.id = r.artist_id
  JOIN genres ON genres.id = r.genre_id
ORDER BY
  artist_name
LIMIT
  100;

-- Part 2: Multiple JOINs
-- Challenge 4. Find all tracks with their artist names AND album names in one query
SELECT
  tracks.name AS track_name,
  artists.name AS artist_name,
  albums.name AS album_name
FROM
  artists
  JOIN r_track_artist rta ON artists.id = rta.artist_id
  JOIN tracks ON tracks.id = rta.track_id
  JOIN r_albums_artists raa ON raa.artist_id = artists.id
  JOIN albums ON albums.id = raa.album_id
WHERE
  tracks."name" IS NOT NULL
ORDER BY
  track_name
LIMIT
  100;

-- Challenge 5. List albums with all their artists (some albums have multiple artists)
SELECT
  albums.name AS album_name,
  artists.name AS artist_name
FROM
  albums
  JOIN r_albums_artists raa ON albums.id = raa.album_id
  JOIN artists ON artists.id = raa.artist_id
ORDER BY
  album_name
LIMIT
  100;

-- Challenge 6. Show tracks with their audio features (danceability, energy, etc.)
SELECT
  t.name AS track_name,
  af.danceability,
  af.duration,
  af.energy AS artist_name
FROM
  tracks t
  JOIN audio_features af ON t.audio_feature_id = af.id
ORDER BY
  t.id
LIMIT
  100;

-- Part 3: Aggregations with JOINs
-- Challenge 7. Find the average popularity of tracks for each artist (minimum 5 tracks)
SELECT
  a.name AS artist_name,
  AVG(t.popularity) AS avg_popularity
FROM
  tracks t
  JOIN r_track_artist rta ON t.id = rta.track_id
  JOIN artists a ON rta.artist_id = a.id
GROUP BY
  a.id
HAVING
  COUNT(rta.track_id) >= 5
LIMIT
  100;

-- Challenge 8. Count how many tracks each album contains
SELECT
  a.name AS album_name,
  COUNT(rat.track_id) AS track_count
FROM
  albums a
  JOIN r_albums_tracks rat ON a.id = rat.album_id
GROUP BY
  a.id
LIMIT
  100;

-- Challenge 9. Find artists with the most albums
SELECT
  ar.name AS artist_name,
  COUNT(raa.album_id) album_count
FROM
  artists ar
  JOIN r_albums_artists raa ON ar.id = raa.artist_id
GROUP BY
  ar.id
ORDER BY
  album_count DESC
LIMIT
  100;

-- Part 4: Complex Queries
-- Challenge 10. Find the most "danceable" track (highest danceability score) for each artist
SELECT
  a.name AS artist_name,
  t.name AS track_name,
  MAX(af.danceability) AS max_danceability
FROM
  tracks t
  JOIN r_track_artist rta ON t.id = rta.track_id
  JOIN artists a ON rta.artist_id = a.id
  JOIN audio_features af ON t.audio_feature_id = af.id
GROUP BY
  a.id
LIMIT
  100;

-- Challenge 11. List albums released in 2020 (hint: convert milliseconds to year) with their artists
SELECT
  albums.name AS album_name,
  artists.name AS artist_name,
  albums.release_date,
  FLOOR(
    1970 + albums.release_date / (365 * 24 * 60 * 60 * 1000)
  ) AS release_year
FROM
  albums
  JOIN r_albums_artists raa ON albums.id = raa.album_id
  JOIN artists ON artists.id = raa.artist_id
WHERE
  FLOOR(
    1970 + albums.release_date / (365 * 24 * 60 * 60 * 1000)
  ) = 2020
ORDER BY
  album_name
LIMIT
  100;

-- Challenge 12. Find artists who appear on albums as collaborators but don't have their own albums
SELECT
  a.name AS artist_name,
  COUNT(raa.album_id) AS album_count
FROM
  artists a
  LEFT JOIN r_albums_artists raa ON a.id = raa.artist_id
GROUP BY
  a.id
HAVING
  COUNT(raa.album_id) = 0
LIMIT
  100;

-- Part 5: Advanced Analysis
-- Challenge 13. Using JOINs and subqueries, find the artist with the highest average track energy
SELECT
  a.name AS artist_name,
  AVG(af.energy) AS avg_energy
FROM
  tracks t
  JOIN r_track_artist rta ON t.id = rta.track_id
  JOIN artists a ON rta.artist_id = a.id
  JOIN audio_features af ON af.id = t.audio_feature_id
GROUP BY
  a.id
ORDER BY
  avg_energy DESC
LIMIT
  1;

-- Challenge 14. Create a query that shows artists who have both high-energy tracks (energy > 0.8) and low-energy tracks (energy < 0.3)
WITH
  artist_energy_cte AS (
    SELECT
      a.name AS artist_name,
      af.energy
    FROM
      tracks t
      JOIN r_track_artist rta ON t.id = rta.track_id
      JOIN artists a ON rta.artist_id = a.id
      JOIN audio_features af ON af.id = t.audio_feature_id
  )
SELECT DISTINCT
  artist_name
FROM
  artist_energy_cte
WHERE
  energy > 0.8
INTERSECT
SELECT DISTINCT
  artist_name
FROM
  artist_energy_cte
WHERE
  energy < 0.3
LIMIT
  100;

-- Challenge 15. Find albums with more than 10 tracks
SELECT
  a.name AS album_name,
  COUNT(rat.track_id) AS track_count
FROM
  albums a
  JOIN r_albums_tracks rat ON a.id = rat.album_id
GROUP BY
  a.id
HAVING
  COUNT(rat.track_id) > 10
LIMIT
  100;

-- Part 6: 🔥 ULTIMATE CHALLENGE 🔥
-- Challenge 16. Find the most popular track for each genre.
SELECT
  rag.genre_id AS genre_id,
  t.name AS track_name,
  MAX(t.popularity) AS max_popularity
FROM
  r_artist_genre rag
  JOIN artists a ON a.id = rag.artist_id
  JOIN r_track_artist rta ON rta.artist_id = a.id
  JOIN tracks t ON t.id = rta.track_id
GROUP BY
  rag.genre_id;

-- Challenge 17. Find the genre with the highest average track popularity
SELECT
  rag.genre_id AS genre_id,
  AVG(t.popularity) AS avg_popularity
FROM
  r_artist_genre rag
  JOIN artists a ON a.id = rag.artist_id
  JOIN r_track_artist rta ON rta.artist_id = a.id
  JOIN tracks t ON t.id = rta.track_id
GROUP BY
  rag.genre_id
ORDER BY
  avg_popularity DESC
LIMIT
  1;

-- Challenge 18. Find tracks longer than 5 minutes (300000 ms) with their artists
SELECT
  t.name AS track_name,
  a.name AS artist_name,
  t.duration
FROM
  artists a
  JOIN r_track_artist rta ON a.id = rta.artist_id
  JOIN tracks t ON t.id = rta.track_id
WHERE
  t.duration > 300000;