-- Recalculate Product Grades Using Nutri-Score
-- This script updates existing products with calculated grades based on their nutrition_facts
-- Run this after implementing the NutriScore calculator

USE nutriapp;

-- Create a temporary stored procedure to calculate Nutri-Score grades
-- This mirrors the logic from the NutriScoreCalculator.cfc component

DELIMITER //
CREATE TEMPORARY PROCEDURE RecalculateProductGrades()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE product_id VARCHAR(36);
    DECLARE nutrition_json TEXT;
    DECLARE calculated_grade CHAR(1);
    
    -- Variables for nutrition values
    DECLARE calories DECIMAL(10,2) DEFAULT 0;
    DECLARE sugar DECIMAL(10,2) DEFAULT 0;
    DECLARE fat DECIMAL(10,2) DEFAULT 0;
    DECLARE fiber DECIMAL(10,2) DEFAULT 0;
    DECLARE protein DECIMAL(10,2) DEFAULT 0;
    
    -- Points variables
    DECLARE calories_points INT DEFAULT 0;
    DECLARE sugar_points INT DEFAULT 0;
    DECLARE fat_points INT DEFAULT 0;
    DECLARE fiber_points INT DEFAULT 0;
    DECLARE protein_points INT DEFAULT 0;
    DECLARE negative_points INT DEFAULT 0;
    DECLARE positive_points INT DEFAULT 0;
    DECLARE nutritional_score INT DEFAULT 0;
    
    -- Cursor to iterate through all products
    DECLARE product_cursor CURSOR FOR 
        SELECT id, nutrition_facts 
        FROM products 
        WHERE nutrition_facts IS NOT NULL 
        AND nutrition_facts != '' 
        AND nutrition_facts != '{}';
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN product_cursor;
    
    products_loop: LOOP
        FETCH product_cursor INTO product_id, nutrition_json;
        IF done THEN
            LEAVE products_loop;
        END IF;
        
        -- Reset values for each product
        SET calories = 0, sugar = 0, fat = 0, fiber = 0, protein = 0;
        SET calculated_grade = 'E'; -- Default grade
        
        -- Extract nutrition values from JSON (with error handling)
        -- Note: This is a simplified approach. In production, you might want more robust JSON parsing
        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET calculated_grade = 'E';
            
            IF JSON_VALID(nutrition_json) THEN
                SET calories = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(nutrition_json, '$.calories')), 0);
                SET sugar = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(nutrition_json, '$.sugar')), 0);
                SET fat = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(nutrition_json, '$.fat')), 0);
                SET fiber = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(nutrition_json, '$.fiber')), 0);
                SET protein = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(nutrition_json, '$.protein')), 0);
                
                -- Calculate Calories Points
                CASE 
                    WHEN calories <= 80 THEN SET calories_points = 0;
                    WHEN calories <= 160 THEN SET calories_points = 1;
                    WHEN calories <= 240 THEN SET calories_points = 2;
                    WHEN calories <= 320 THEN SET calories_points = 3;
                    WHEN calories <= 400 THEN SET calories_points = 4;
                    WHEN calories <= 480 THEN SET calories_points = 5;
                    WHEN calories <= 560 THEN SET calories_points = 6;
                    WHEN calories <= 640 THEN SET calories_points = 7;
                    WHEN calories <= 720 THEN SET calories_points = 8;
                    WHEN calories <= 800 THEN SET calories_points = 9;
                    ELSE SET calories_points = 10;
                END CASE;
                
                -- Calculate Sugar Points
                CASE
                    WHEN sugar <= 4.5 THEN SET sugar_points = 0;
                    WHEN sugar <= 9 THEN SET sugar_points = 1;
                    WHEN sugar <= 13.5 THEN SET sugar_points = 2;
                    WHEN sugar <= 18 THEN SET sugar_points = 3;
                    WHEN sugar <= 22.5 THEN SET sugar_points = 4;
                    WHEN sugar <= 27 THEN SET sugar_points = 5;
                    WHEN sugar <= 31 THEN SET sugar_points = 6;
                    WHEN sugar <= 36 THEN SET sugar_points = 7;
                    WHEN sugar <= 40 THEN SET sugar_points = 8;
                    WHEN sugar <= 45 THEN SET sugar_points = 9;
                    ELSE SET sugar_points = 10;
                END CASE;
                
                -- Calculate Fat Points
                CASE
                    WHEN fat <= 1 THEN SET fat_points = 0;
                    WHEN fat <= 2 THEN SET fat_points = 1;
                    WHEN fat <= 3 THEN SET fat_points = 2;
                    WHEN fat <= 4 THEN SET fat_points = 3;
                    WHEN fat <= 5 THEN SET fat_points = 4;
                    WHEN fat <= 6 THEN SET fat_points = 5;
                    WHEN fat <= 7 THEN SET fat_points = 6;
                    WHEN fat <= 8 THEN SET fat_points = 7;
                    WHEN fat <= 9 THEN SET fat_points = 8;
                    WHEN fat <= 10 THEN SET fat_points = 9;
                    ELSE SET fat_points = 10;
                END CASE;
                
                -- Calculate Fiber Points
                CASE
                    WHEN fiber <= 0.9 THEN SET fiber_points = 0;
                    WHEN fiber <= 1.9 THEN SET fiber_points = 1;
                    WHEN fiber <= 2.8 THEN SET fiber_points = 2;
                    WHEN fiber <= 3.7 THEN SET fiber_points = 3;
                    WHEN fiber <= 4.7 THEN SET fiber_points = 4;
                    ELSE SET fiber_points = 5;
                END CASE;
                
                -- Calculate Protein Points
                CASE
                    WHEN protein <= 1.6 THEN SET protein_points = 0;
                    WHEN protein <= 3.2 THEN SET protein_points = 1;
                    WHEN protein <= 4.8 THEN SET protein_points = 2;
                    WHEN protein <= 6.4 THEN SET protein_points = 3;
                    WHEN protein <= 8.0 THEN SET protein_points = 4;
                    ELSE SET protein_points = 5;
                END CASE;
                
                -- Calculate final score
                SET negative_points = calories_points + sugar_points + fat_points;
                SET positive_points = fiber_points + protein_points;
                SET nutritional_score = negative_points - positive_points;
                
                -- Determine grade
                CASE
                    WHEN nutritional_score <= -1 THEN SET calculated_grade = 'A';
                    WHEN nutritional_score >= 0 AND nutritional_score <= 2 THEN SET calculated_grade = 'B';
                    WHEN nutritional_score >= 3 AND nutritional_score <= 10 THEN SET calculated_grade = 'C';
                    WHEN nutritional_score >= 11 AND nutritional_score <= 18 THEN SET calculated_grade = 'D';
                    ELSE SET calculated_grade = 'E';
                END CASE;
            END IF;
        END;
        
        -- Update the product with the calculated grade
        UPDATE products 
        SET rating = calculated_grade, 
            updated_at = NOW() 
        WHERE id = product_id;
        
        -- Output progress (optional)
        SELECT CONCAT('Updated product ', product_id, ' with grade ', calculated_grade) as progress_message;
        
    END LOOP;
    
    CLOSE product_cursor;
END //
DELIMITER ;

-- Show current grade distribution before update
SELECT 'BEFORE UPDATE:' as status, rating, COUNT(*) as count 
FROM products 
GROUP BY rating 
ORDER BY rating;

-- Execute the recalculation
CALL RecalculateProductGrades();

-- Show final grade distribution after update  
SELECT 'AFTER UPDATE:' as status, rating, COUNT(*) as count 
FROM products 
GROUP BY rating 
ORDER BY rating;

-- Drop the temporary procedure
DROP TEMPORARY PROCEDURE RecalculateProductGrades;

-- Final summary
SELECT 
    'RECALCULATION COMPLETE' as status,
    COUNT(*) as total_products_updated,
    NOW() as completion_time
FROM products 
WHERE nutrition_facts IS NOT NULL 
AND nutrition_facts != '' 
AND nutrition_facts != '{}';
