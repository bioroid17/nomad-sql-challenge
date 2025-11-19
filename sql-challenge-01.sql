-- Part 1: Basic Queries
-- Challenge 1: Find the 10 longest books (by pages) in the database
SELECT title, pages FROM books ORDER BY pages DESC LIMIT 10;
-- Challenge 2: List all books published in 2020
SELECT title, published_date FROM books WHERE published_date = 2020;
-- Challenge 3: Find books with ratings between 4.5 and 5.0
SELECT title, average_rating FROM books WHERE average_rating BETWEEN 4.5 AND 5.0 LIMIT 100;

-- Part 2: Aggregate Functions
-- Challenge 4: Calculate the average number of pages for all books
SELECT AVG(pages) AS avg_pages FROM books;
-- Challenge 5: Find the total number of books published each year from 2015 to 2023
SELECT COUNT(*) AS book_count FROM books WHERE published_date BETWEEN 2015 AND 2023;
-- Challenge 6: What is the average rating of books with more than 500 pages?
SELECT AVG(average_rating) AS avg_rating FROM books WHERE pages > 500;

-- Part 3: GROUP BY and HAVING
-- Challenge 7: Find the top 10 most prolific authors (by number of books)
SELECT author, COUNT(*) AS book_count FROM books GROUP BY author ORDER BY book_count DESC LIMIT 10;
-- Challenge 8: List authors who have an average book rating above 4.0 (minimum 5 books)
SELECT author, AVG(average_rating) AS avg_rating, COUNT(*) AS book_count FROM books GROUP BY author HAVING COUNT(*) >= 5;
-- Challenge 9: Show the average pages per book for each year, but only for years with more than 1000 books
SELECT published_date, AVG(pages) AS avg_pages FROM books GROUP BY published_date HAVING COUNT(*) > 1000 ORDER BY published_date;

-- Part 4: Subqueries
-- Challenge 10: Find all books that have more pages than the average
SELECT title, pages FROM books WHERE pages > (SELECT AVG(pages) FROM books) LIMIT 20;
-- Challenge 11: List authors whose average rating is higher than the overall average rating
SELECT author, AVG(average_rating) AS avg_rating FROM books GROUP BY author HAVING AVG(average_rating) > (SELECT AVG(average_rating) FROM books) LIMIT 20;
-- Challenge 12: Find books published in the same year as the highest-rated book
SELECT title, published_date FROM books WHERE published_date = (SELECT published_date FROM books ORDER BY average_rating DESC LIMIT 1) LIMIT 10;

-- Part 5: CTEs
-- Challenge 13: Using a CTE, identify "prolific authors" (more than 20 books) and then find their highest-rated book
WITH prolific_authors_cte AS (SELECT author, MAX(average_rating) AS max_avg_rating FROM books GROUP BY author HAVING COUNT(*) > 20),
max_rating_cte AS (SELECT max_avg_rating FROM prolific_authors_cte WHERE prolific_authors_cte.author = main_books.author)
SELECT title, author, average_rating AS max_avg_rating, (SELECT max_avg_rating FROM max_rating_cte) AS max_avg_rating FROM books AS main_books
WHERE average_rating = (SELECT max_avg_rating FROM max_rating_cte) ORDER BY author LIMIT 150;
-- Challenge 14: Create a CTE that categorizes books by length (Short: <200, Medium: 200-400, Long: >400 pages) and show the average rating for each category
WITH length_cte AS (SELECT title, average_rating, CASE WHEN pages < 200 THEN 'Short' WHEN pages > 400 THEN 'Long' ELSE 'Medium' END AS length FROM books)
SELECT AVG(average_rating), length FROM length_cte GROUP BY length;
-- Challenge 15: Write a CTE to find the best book (highest rating) for each year from 2010-2023, excluding books with less than 10 pages
WITH best_book_cte AS (SELECT published_date, COUNT(*) AS book_count, MAX(average_rating) AS max_avg_rating FROM books WHERE pages > 10 AND published_date BETWEEN 2010 AND 2023 GROUP BY published_date)
SELECT title, author, average_rating, published_date FROM books AS main_books
WHERE main_books.average_rating = (SELECT max_avg_rating FROM best_book_cte WHERE main_books.published_date BETWEEN (SELECT MIN(published_date) FROM best_book_cte) AND (SELECT MAX(published_date) FROM best_book_cte))
ORDER BY title LIMIT 100;

WITH best_book_cte AS (SELECT published_date, COUNT(*) AS book_count, MAX(average_rating) AS max_avg_rating FROM books WHERE pages > 10 AND published_date BETWEEN 2010 AND 2023 GROUP BY published_date)
SELECT title, author, average_rating, published_date FROM books AS main_books
WHERE main_books.average_rating = (SELECT max_avg_rating FROM best_book_cte WHERE main_books.published_date IN (SELECT published_date FROM best_book_cte))
ORDER BY title LIMIT 100;

-- Part 6: 🔥 ULTIMATE CHALLENGE 🔥
-- Challenge 16: Find authors who have written at least 10 books where EVERY single book has a rating within 0.5 points of their average rating (meaning they're incredibly consistent). Use CTEs and subqueries to solve this.
WITH least_ten_books_cte AS (SELECT author, COUNT(*) book_count, AVG(average_rating) avg_average_rating FROM books AS ltbc_books GROUP BY author HAVING COUNT(*) >= 10 LIMIT 1000)
SELECT DISTINCT main_books.author FROM books AS main_books WHERE ABS(main_books.average_rating - (SELECT avg_average_rating FROM least_ten_books_cte WHERE main_books.author = author)) <= 0.5;
-- Challenge 17: Using subqueries and CTEs, identify books that have:
--      * Below average page count for their year
--      * Above average rating for short books (under 300 pages)
--      * Written by authors who typically write long books (average > 400 pages)
-- This finds short books that are unusually good from authors who usually write long books. Show the book title, author, pages, and rating.
WITH under_avg_page_cte AS (SELECT published_date, AVG(pages) avg_pages FROM books AS uapc_books GROUP BY published_date),
short_book_avg_rating_cte AS (SELECT AVG(average_rating) avg_average_rating FROM books WHERE pages < 300),
long_book_author_cte AS (SELECT author FROM books GROUP BY author HAVING AVG(pages) > 400)
SELECT main_books.title, main_books.author, main_books.pages, main_books.average_rating, main_books.published_date FROM books AS main_books
WHERE main_books.pages < (SELECT avg_pages FROM under_avg_page_cte WHERE main_books.published_date = published_date)
AND main_books.average_rating > (SELECT avg_average_rating FROM short_book_avg_rating_cte)
AND main_books.author IN (SELECT author FROM long_book_author_cte);
-- Challenge 18: Using CTEs, find the single most dominant author of each decade (1950s, 1960s, 1970s, etc.). "Dominant" means they had the most books with ratings above 4.0 in that decade. For ties, use total number of books as tiebreaker. Show the decade, author, number of highly-rated books, and their average rating for that decade.
WITH decade_author_cte AS (SELECT FLOOR(published_date / 10) * 10 AS decade, author, COUNT(author) book_count, AVG(average_rating) avg_average_rating FROM books WHERE average_rating > 4.0 GROUP BY decade, author ORDER BY decade, book_count DESC)
SELECT decade, author, MAX(book_count) max_book_count, avg_average_rating FROM decade_author_cte GROUP BY decade;