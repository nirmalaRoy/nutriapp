-- Populate NutriApp database with initial product data
-- This migrates data from MockData.cfc to MySQL

USE nutriapp;

-- Insert products from MockData.cfc
INSERT INTO products (id, name, brand, category, rating, description, ingredients, nutrition_facts, price, created_at) VALUES
-- Protein Powders
('protein1', 'Premium Organic Whey Isolate', 'PureFit', 'protein_powder', 'A', 'Grass-fed whey protein isolate with no artificial additives. 30g protein per serving.', 
 '["Organic Whey Protein Isolate", "Natural Vanilla", "Stevia"]', 
 '{"calories": 110, "protein": 30, "carbs": 1, "fat": 0.5, "saturatedFat": 0.2, "transFat": 0, "fiber": 0, "sugar": 0, "sodium": 50, "cholesterol": 5, "calcium": 120, "iron": 2.5, "vitaminC": 0, "potassium": 180}', 
 4999, '2024-01-01 00:00:00'),

('protein2', 'Plant-Based Complete Protein', 'GreenPower', 'protein_powder', 'A', 'Complete amino acid profile from pea and hemp protein. Vegan-friendly.', 
 '["Pea Protein", "Hemp Protein", "Natural Chocolate", "Monk Fruit"]', 
 '{"calories": 120, "protein": 25, "carbs": 3, "fat": 2, "saturatedFat": 0.5, "transFat": 0, "fiber": 4, "sugar": 1, "sodium": 80, "cholesterol": 0, "calcium": 90, "iron": 4.2, "vitaminC": 2, "potassium": 220}', 
 4199, '2024-01-01 00:00:00'),

('protein3', 'Standard Whey Concentrate', 'FitLife', 'protein_powder', 'B', 'Quality whey concentrate with good protein content. Contains some lactose.', 
 '["Whey Protein Concentrate", "Natural Flavors", "Sucralose"]', 
 '{"calories": 130, "protein": 24, "carbs": 4, "fat": 2, "fiber": 1, "sugar": 3}', 
 2899, '2024-01-01 00:00:00'),

('protein4', 'Basic Protein Blend', 'MuscleMax', 'protein_powder', 'C', 'Affordable protein blend with decent quality. Contains multiple protein sources.', 
 '["Whey Concentrate", "Soy Protein", "Artificial Flavors", "Aspartame"]', 
 '{"calories": 140, "protein": 20, "carbs": 6, "fat": 3, "fiber": 1, "sugar": 5}', 
 1999, '2024-01-01 00:00:00'),

('protein5', 'Budget Protein Mix', 'CheapGains', 'protein_powder', 'D', 'Low-cost protein with many fillers and artificial ingredients.', 
 '["Soy Protein", "Wheat Protein", "Artificial Colors", "High Fructose Corn Syrup"]', 
 '{"calories": 160, "protein": 15, "carbs": 12, "fat": 4, "fiber": 2, "sugar": 8}', 
 1599, '2024-01-01 00:00:00'),

-- Chips
('chips1', 'Organic Sweet Potato Chips', 'PureEarth', 'chips', 'A', 'Baked sweet potato chips with no added oils. High in fiber and vitamins.', 
 '["Organic Sweet Potatoes", "Sea Salt"]', 
 '{"calories": 120, "protein": 2, "carbs": 27, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 4, "sugar": 6, "sodium": 15, "cholesterol": 0, "calcium": 35, "iron": 0.8, "vitaminC": 8, "potassium": 340}', 
 399, '2024-01-01 00:00:00'),

('chips2', 'Air-Popped Kale Chips', 'GreenSnack', 'chips', 'A', 'Dehydrated kale chips with nutritional yeast. Packed with vitamins and minerals.', 
 '["Organic Kale", "Nutritional Yeast", "Sea Salt", "Olive Oil"]', 
 '{"calories": 50, "protein": 3, "carbs": 7, "fat": 1, "fiber": 2, "sugar": 0}', 
 449, '2024-01-01 00:00:00'),

('chips3', 'Kettle-Cooked Avocado Oil Chips', 'HealthyChoice', 'chips', 'B', 'Potato chips cooked in avocado oil with reduced sodium.', 
 '["Potatoes", "Avocado Oil", "Sea Salt"]', 
 '{"calories": 140, "protein": 2, "carbs": 16, "fat": 8, "fiber": 2, "sugar": 0}', 
 329, '2024-01-01 00:00:00'),

('chips4', 'Classic Potato Chips', 'GoldenCrisp', 'chips', 'C', 'Traditional potato chips with moderate salt content.', 
 '["Potatoes", "Vegetable Oil", "Salt"]', 
 '{"calories": 160, "protein": 2, "carbs": 15, "fat": 10, "fiber": 1, "sugar": 0}', 
 249, '2024-01-01 00:00:00'),

('chips5', 'Cheesy Flavor Blast', 'CrunchTime', 'chips', 'D', 'Heavily processed chips with artificial cheese flavoring and preservatives.', 
 '["Corn", "Vegetable Oil", "Cheese Powder", "Monosodium Glutamate", "Artificial Colors"]', 
 '{"calories": 180, "protein": 2, "carbs": 16, "fat": 12, "saturatedFat": 3, "transFat": 2, "fiber": 1, "sugar": 2, "sodium": 420, "cholesterol": 0, "calcium": 15, "iron": 0.8, "vitaminC": 0, "potassium": 120}', 
 159, '2024-01-01 00:00:00'),

-- Chocolates
('chocolate1', '85% Dark Chocolate Bar', 'PureCacao', 'chocolates', 'A', 'Organic dark chocolate with high cacao content. Rich in antioxidants.', 
 '["Organic Cacao", "Organic Cane Sugar", "Organic Cacao Butter"]', 
 '{"calories": 170, "protein": 4, "carbs": 13, "fat": 12, "saturatedFat": 7, "transFat": 0, "fiber": 5, "sugar": 7, "sodium": 5, "cholesterol": 0, "calcium": 25, "iron": 3.2, "vitaminC": 0, "potassium": 200}', 
 399, '2024-01-01 00:00:00'),

('chocolate2', 'Raw Cacao Superfood Bar', 'EarthBar', 'chocolates', 'A', 'Raw chocolate bar with superfoods and no refined sugar.', 
 '["Raw Cacao", "Coconut Sugar", "Almonds", "Goji Berries", "Chia Seeds"]', 
 '{"calories": 150, "protein": 3, "carbs": 16, "fat": 8, "fiber": 4, "sugar": 10}', 
 579, '2024-01-01 00:00:00'),

('chocolate3', '70% Dark Chocolate', 'CocoaDelight', 'chocolates', 'B', 'Good quality dark chocolate with moderate sugar content.', 
 '["Cacao", "Sugar", "Cacao Butter", "Vanilla"]', 
 '{"calories": 180, "protein": 3, "carbs": 17, "fat": 11, "fiber": 3, "sugar": 12}', 
 289, '2024-01-01 00:00:00'),

('chocolate4', 'Milk Chocolate Classic', 'SweetTooth', 'chocolates', 'C', 'Traditional milk chocolate with standard ingredients.', 
 '["Sugar", "Cocoa Butter", "Milk Powder", "Cocoa", "Vanilla"]', 
 '{"calories": 210, "protein": 3, "carbs": 22, "fat": 13, "fiber": 1, "sugar": 20}', 
 199, '2024-01-01 00:00:00'),

('chocolate5', 'Candy Bar Supreme', 'SugarRush', 'chocolates', 'D', 'Chocolate candy bar with caramel, nougat, and lots of added sugars.', 
 '["Corn Syrup", "Sugar", "Partially Hydrogenated Oils", "Artificial Flavors", "Preservatives"]', 
 '{"calories": 250, "protein": 2, "carbs": 35, "fat": 12, "fiber": 1, "sugar": 28}', 
 159, '2024-01-01 00:00:00'),

-- Popcorn
('popcorn1', 'Organic Air-Popped Popcorn', 'PurePop', 'popcorn', 'A', 'Air-popped organic popcorn with no added oils or artificial ingredients.', 
 '["Organic Popcorn", "Sea Salt"]', 
 '{"calories": 30, "protein": 1, "carbs": 6, "fat": 0, "fiber": 1, "sugar": 0}', 
 329, '2024-01-01 00:00:00'),

('popcorn2', 'Coconut Oil Popped Corn', 'HealthySnap', 'popcorn', 'B', 'Popcorn popped in coconut oil with minimal salt.', 
 '["Popcorn", "Organic Coconut Oil", "Sea Salt"]', 
 '{"calories": 40, "protein": 1, "carbs": 5, "fat": 2, "fiber": 1, "sugar": 0}', 
 369, '2024-01-01 00:00:00'),

('popcorn3', 'Microwave Butter Popcorn', 'QuickPop', 'popcorn', 'C', 'Convenient microwave popcorn with butter flavoring.', 
 '["Popcorn", "Palm Oil", "Salt", "Natural Butter Flavor"]', 
 '{"calories": 50, "protein": 1, "carbs": 6, "fat": 3, "fiber": 1, "sugar": 0}', 
 249, '2024-01-01 00:00:00'),

('popcorn4', 'Cheese Powder Explosion', 'FlavorBlast', 'popcorn', 'D', 'Heavily processed popcorn with artificial cheese powder and preservatives.', 
 '["Popcorn", "Vegetable Oil", "Cheese Powder", "Artificial Colors", "Preservatives"]', 
 '{"calories": 70, "protein": 2, "carbs": 7, "fat": 4, "fiber": 1, "sugar": 1}', 
 159, '2024-01-01 00:00:00'),

-- Biscuits
('biscuit1', 'Organic Oat & Seed Crackers', 'WholeSome', 'biscuits', 'A', 'Whole grain crackers with seeds and no refined sugars.', 
 '["Organic Oats", "Sunflower Seeds", "Flax Seeds", "Sea Salt", "Olive Oil"]', 
 '{"calories": 120, "protein": 4, "carbs": 18, "fat": 4, "fiber": 3, "sugar": 1}', 
 399, '2024-01-01 00:00:00'),

('biscuit2', 'Whole Wheat Digestive Biscuits', 'FiberFirst', 'biscuits', 'B', 'Whole wheat biscuits with moderate sugar and good fiber content.', 
 '["Whole Wheat Flour", "Sugar", "Vegetable Oil", "Salt", "Baking Powder"]', 
 '{"calories": 140, "protein": 3, "carbs": 22, "fat": 5, "fiber": 2, "sugar": 8}', 
 289, '2024-01-01 00:00:00'),

('biscuit3', 'Classic Tea Biscuits', 'TeaTime', 'biscuits', 'C', 'Traditional tea biscuits with moderate ingredients.', 
 '["Wheat Flour", "Sugar", "Butter", "Eggs", "Baking Powder"]', 
 '{"calories": 160, "protein": 2, "carbs": 24, "fat": 6, "fiber": 1, "sugar": 12}', 
 249, '2024-01-01 00:00:00'),

('biscuit4', 'Double Chocolate Cookies', 'SweetIndulgence', 'biscuits', 'D', 'High-sugar cookies with chocolate chips and artificial ingredients.', 
 '["Refined Flour", "Sugar", "Palm Oil", "Chocolate Chips", "Artificial Vanilla", "Preservatives"]', 
 '{"calories": 200, "protein": 2, "carbs": 28, "fat": 9, "fiber": 1, "sugar": 18}', 
 199, '2024-01-01 00:00:00'),

('biscuit5', 'Frosted Sugar Cookies', 'CandyLand', 'biscuits', 'E', 'Highly processed cookies with excessive sugar, artificial colors, and preservatives.', 
 '["White Flour", "High Fructose Corn Syrup", "Hydrogenated Oils", "Artificial Colors", "Preservatives", "Artificial Flavors"]', 
 '{"calories": 250, "protein": 1, "carbs": 38, "fat": 11, "fiber": 0, "sugar": 25}', 
 159, '2024-01-01 00:00:00'),

-- Cereals
('cereal1', 'Organic Steel-Cut Oatmeal', 'NaturesPure', 'cereals', 'A', 'Minimally processed steel-cut oats with no added sugars. High in fiber and protein.', 
 '["Organic Steel-Cut Oats"]', 
 '{"calories": 150, "protein": 5, "carbs": 27, "fat": 3, "saturatedFat": 0.5, "transFat": 0, "fiber": 4, "sugar": 0, "sodium": 0, "cholesterol": 0, "calcium": 20, "iron": 2.1, "vitaminC": 0, "potassium": 164}', 
 449, '2024-01-01 00:00:00'),

('cereal2', 'Ancient Grains Muesli', 'WholeFoods', 'cereals', 'A', 'Organic muesli with quinoa, amaranth, and dried fruits. No added sugars.', 
 '["Organic Oats", "Organic Quinoa", "Organic Amaranth", "Organic Raisins", "Organic Almonds", "Organic Sunflower Seeds"]', 
 '{"calories": 160, "protein": 6, "carbs": 32, "fat": 3, "saturatedFat": 0.5, "transFat": 0, "fiber": 5, "sugar": 8, "sodium": 5, "cholesterol": 0, "calcium": 45, "iron": 2.8, "vitaminC": 2, "potassium": 220}', 
 599, '2024-01-01 00:00:00'),

('cereal3', 'High-Fiber Bran Flakes', 'FiberFirst', 'cereals', 'B', 'Whole grain wheat bran cereal with moderate sugar content.', 
 '["Whole Wheat Bran", "Sugar", "Salt", "Iron", "Folic Acid"]', 
 '{"calories": 120, "protein": 4, "carbs": 30, "fat": 1, "saturatedFat": 0, "transFat": 0, "fiber": 10, "sugar": 6, "sodium": 125, "cholesterol": 0, "calcium": 15, "iron": 18, "vitaminC": 15, "potassium": 190}', 
 369, '2024-01-01 00:00:00'),

('cereal4', 'Honey Nut Crunch', 'GoldenGrain', 'cereals', 'B', 'Whole grain oat cereal with honey and almonds. Moderate sugar content.', 
 '["Whole Grain Oats", "Honey", "Almonds", "Natural Flavors", "Salt"]', 
 '{"calories": 140, "protein": 3, "carbs": 29, "fat": 2, "saturatedFat": 0.5, "transFat": 0, "fiber": 3, "sugar": 9, "sodium": 190, "cholesterol": 0, "calcium": 20, "iron": 4.5, "vitaminC": 10, "potassium": 95}', 
 329, '2024-01-01 00:00:00'),

('cereal5', 'Corn Flakes Classic', 'MorningCrunch', 'cereals', 'C', 'Traditional corn flakes with moderate processing and added vitamins.', 
 '["Milled Corn", "Sugar", "Salt", "Iron", "Vitamins A, B, C, D"]', 
 '{"calories": 110, "protein": 2, "carbs": 24, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 1, "sugar": 3, "sodium": 200, "cholesterol": 0, "calcium": 10, "iron": 8.1, "vitaminC": 10, "potassium": 30}', 
 279, '2024-01-01 00:00:00'),

('cereal6', 'Chocolate Crunch Balls', 'SweetMorning', 'cereals', 'D', 'Chocolate-flavored cereal balls with high sugar content and artificial flavors.', 
 '["Corn Flour", "Sugar", "Cocoa", "Artificial Chocolate Flavor", "Preservatives", "Artificial Colors"]', 
 '{"calories": 140, "protein": 2, "carbs": 32, "fat": 2, "saturatedFat": 1, "transFat": 0, "fiber": 1, "sugar": 15, "sodium": 180, "cholesterol": 0, "calcium": 15, "iron": 4.5, "vitaminC": 6, "potassium": 55}', 
 249, '2024-01-01 00:00:00'),

('cereal7', 'Frosted Loops Supreme', 'SugarRush', 'cereals', 'E', 'Heavily processed cereal rings with excessive sugar, artificial colors, and preservatives.', 
 '["Corn Flour", "High Fructose Corn Syrup", "Artificial Colors (Red 40, Blue 1, Yellow 6)", "BHT Preservative", "Artificial Flavors"]', 
 '{"calories": 150, "protein": 1, "carbs": 36, "fat": 1, "saturatedFat": 0.5, "transFat": 0, "fiber": 0, "sugar": 20, "sodium": 140, "cholesterol": 0, "calcium": 10, "iron": 4.5, "vitaminC": 10, "potassium": 25}', 
 219, '2024-01-01 00:00:00'),

-- Nuts
('nuts1', 'Raw Organic Almonds', 'NutHarvest', 'nuts', 'A', 'Raw, unsalted organic almonds. Rich in healthy fats, protein, and vitamin E.', 
 '["Organic Raw Almonds"]', 
 '{"calories": 170, "protein": 6, "carbs": 6, "fat": 15, "saturatedFat": 1, "transFat": 0, "fiber": 4, "sugar": 1, "sodium": 0, "cholesterol": 0, "calcium": 75, "iron": 1, "vitaminC": 0, "potassium": 200}', 
 899, '2024-01-01 00:00:00'),

('nuts2', 'Mixed Raw Nuts', 'PureNuts', 'nuts', 'A', 'Premium mix of raw almonds, walnuts, cashews, and Brazil nuts. No salt or oil added.', 
 '["Organic Almonds", "Organic Walnuts", "Organic Cashews", "Organic Brazil Nuts"]', 
 '{"calories": 180, "protein": 5, "carbs": 7, "fat": 16, "saturatedFat": 2.5, "transFat": 0, "fiber": 3, "sugar": 2, "sodium": 0, "cholesterol": 0, "calcium": 65, "iron": 1.5, "vitaminC": 0, "potassium": 190}', 
 1299, '2024-01-01 00:00:00'),

('nuts3', 'Lightly Salted Cashews', 'HealthySnack', 'nuts', 'B', 'Dry roasted cashews with minimal sea salt. Good source of healthy fats.', 
 '["Cashews", "Sea Salt"]', 
 '{"calories": 160, "protein": 5, "carbs": 9, "fat": 13, "saturatedFat": 2.5, "transFat": 0, "fiber": 1, "sugar": 2, "sodium": 85, "cholesterol": 0, "calcium": 10, "iron": 1.7, "vitaminC": 0, "potassium": 160}', 
 799, '2024-01-01 00:00:00'),

('nuts4', 'Honey Roasted Peanuts', 'SweetNuts', 'nuts', 'B', 'Peanuts roasted with honey and minimal salt. Good protein source with moderate sugar.', 
 '["Peanuts", "Honey", "Salt", "Natural Flavors"]', 
 '{"calories": 170, "protein": 7, "carbs": 8, "fat": 14, "saturatedFat": 2, "transFat": 0, "fiber": 2, "sugar": 4, "sodium": 90, "cholesterol": 0, "calcium": 15, "iron": 0.9, "vitaminC": 0, "potassium": 200}', 
 549, '2024-01-01 00:00:00'),

('nuts5', 'Salted Mixed Nuts', 'BarSnack', 'nuts', 'C', 'Roasted mixed nuts with moderate salt content. Contains peanuts and tree nuts.', 
 '["Peanuts", "Almonds", "Cashews", "Vegetable Oil", "Salt"]', 
 '{"calories": 180, "protein": 6, "carbs": 6, "fat": 16, "saturatedFat": 2.5, "transFat": 0, "fiber": 3, "sugar": 1, "sodium": 150, "cholesterol": 0, "calcium": 40, "iron": 1.2, "vitaminC": 0, "potassium": 180}', 
 449, '2024-01-01 00:00:00'),

('nuts6', 'Chocolate Covered Almonds', 'SweetTreat', 'nuts', 'D', 'Almonds covered in milk chocolate. High in sugar and processed ingredients.', 
 '["Almonds", "Milk Chocolate (Sugar, Cocoa Butter, Milk)", "Confectioner\'s Glaze", "Artificial Flavors"]', 
 '{"calories": 200, "protein": 4, "carbs": 20, "fat": 13, "saturatedFat": 5, "transFat": 0, "fiber": 3, "sugar": 16, "sodium": 20, "cholesterol": 5, "calcium": 60, "iron": 1, "vitaminC": 0, "potassium": 150}', 
 699, '2024-01-01 00:00:00'),

('nuts7', 'Candied Walnuts', 'SugarCoated', 'nuts', 'E', 'Walnuts heavily coated in sugar syrup with artificial flavors and preservatives.', 
 '["Walnuts", "Corn Syrup", "Sugar", "Artificial Maple Flavor", "Preservatives", "Artificial Colors"]', 
 '{"calories": 220, "protein": 3, "carbs": 25, "fat": 14, "saturatedFat": 1.5, "transFat": 0, "fiber": 2, "sugar": 22, "sodium": 45, "cholesterol": 0, "calcium": 25, "iron": 0.8, "vitaminC": 0, "potassium": 120}', 
 599, '2024-01-01 00:00:00'),

-- Energy Bars
('energy1', 'Raw Organic Fruit & Nut Bar', 'PureEnergy', 'energy_bars', 'A', 'Raw food bar made with dates, almonds, and superfruits. No processing or added sugars.', 
 '["Organic Dates", "Organic Almonds", "Organic Goji Berries", "Organic Chia Seeds"]', 
 '{"calories": 190, "protein": 6, "carbs": 24, "fat": 9, "saturatedFat": 1, "transFat": 0, "fiber": 5, "sugar": 16, "sodium": 5, "cholesterol": 0, "calcium": 80, "iron": 1.8, "vitaminC": 2, "potassium": 350}', 
 299, '2024-01-01 00:00:00'),

('energy2', 'Plant-Based Protein Bar', 'GreenPower', 'energy_bars', 'A', 'Organic protein bar with 20g plant protein. Made with whole food ingredients.', 
 '["Organic Pea Protein", "Organic Dates", "Organic Almond Butter", "Organic Cacao", "Organic Coconut"]', 
 '{"calories": 220, "protein": 20, "carbs": 18, "fat": 8, "saturatedFat": 3, "transFat": 0, "fiber": 6, "sugar": 12, "sodium": 45, "cholesterol": 0, "calcium": 100, "iron": 3.2, "vitaminC": 0, "potassium": 280}', 
 349, '2024-01-01 00:00:00'),

('energy3', 'Granola Energy Bar', 'TrailMix', 'energy_bars', 'B', 'Oat-based granola bar with nuts and dried fruits. Moderate sugar from natural sources.', 
 '["Oats", "Honey", "Almonds", "Dried Cranberries", "Sunflower Seeds", "Cinnamon"]', 
 '{"calories": 180, "protein": 4, "carbs": 28, "fat": 6, "saturatedFat": 1, "transFat": 0, "fiber": 3, "sugar": 14, "sodium": 65, "cholesterol": 0, "calcium": 45, "iron": 1.5, "vitaminC": 1, "potassium": 140}', 
 249, '2024-01-01 00:00:00'),

('energy4', 'Whey Protein Bar', 'FitLife', 'energy_bars', 'B', 'Protein bar with whey isolate and moderate processing. Good protein content.', 
 '["Whey Protein Isolate", "Almonds", "Dates", "Natural Flavors", "Stevia"]', 
 '{"calories": 200, "protein": 18, "carbs": 15, "fat": 8, "saturatedFat": 2, "transFat": 0, "fiber": 4, "sugar": 8, "sodium": 150, "cholesterol": 15, "calcium": 120, "iron": 2, "vitaminC": 0, "potassium": 200}', 
 279, '2024-01-01 00:00:00'),

('energy5', 'Chocolate Chip Granola Bar', 'QuickEnergy', 'energy_bars', 'C', 'Standard granola bar with chocolate chips and moderate processing.', 
 '["Oats", "Brown Rice Syrup", "Chocolate Chips", "Peanut Butter", "Salt"]', 
 '{"calories": 190, "protein": 5, "carbs": 25, "fat": 8, "saturatedFat": 3, "transFat": 0, "fiber": 2, "sugar": 12, "sodium": 125, "cholesterol": 0, "calcium": 20, "iron": 1.8, "vitaminC": 0, "potassium": 110}', 
 199, '2024-01-01 00:00:00'),

('energy6', 'High-Sugar Energy Bar', 'PowerBoost', 'energy_bars', 'D', 'Processed energy bar with high sugar content and artificial ingredients.', 
 '["Corn Syrup", "Soy Protein", "Sugar", "Palm Oil", "Artificial Flavors", "Preservatives"]', 
 '{"calories": 240, "protein": 10, "carbs": 35, "fat": 8, "saturatedFat": 4, "transFat": 1, "fiber": 1, "sugar": 22, "sodium": 200, "cholesterol": 0, "calcium": 40, "iron": 2.7, "vitaminC": 15, "potassium": 85}', 
 179, '2024-01-01 00:00:00'),

('energy7', 'Candy Bar Energy', 'SweetRush', 'energy_bars', 'E', 'Candy-like energy bar with excessive sugar, artificial colors, and trans fats.', 
 '["High Fructose Corn Syrup", "Hydrogenated Oils", "Artificial Colors", "Artificial Flavors", "Preservatives", "Modified Corn Starch"]', 
 '{"calories": 280, "protein": 3, "carbs": 42, "fat": 12, "saturatedFat": 6, "transFat": 3, "fiber": 0, "sugar": 35, "sodium": 250, "cholesterol": 0, "calcium": 20, "iron": 1.8, "vitaminC": 10, "potassium": 50}', 
 149, '2024-01-01 00:00:00'),

-- Drinks
('drink1', 'Cold-Pressed Green Juice', 'FreshVeggies', 'drinks', 'A', 'Organic cold-pressed juice with kale, spinach, cucumber, and apple. No added sugars.', 
 '["Organic Kale", "Organic Spinach", "Organic Cucumber", "Organic Apple", "Organic Lemon"]', 
 '{"calories": 45, "protein": 3, "carbs": 9, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 1, "sugar": 6, "sodium": 15, "cholesterol": 0, "calcium": 90, "iron": 2.1, "vitaminC": 45, "potassium": 350}', 
 599, '2024-01-01 00:00:00'),

('drink2', 'Organic Coconut Water', 'TropicalPure', 'drinks', 'A', 'Pure coconut water with no added sugars or preservatives. Natural electrolytes.', 
 '["Organic Coconut Water"]', 
 '{"calories": 45, "protein": 2, "carbs": 9, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 3, "sugar": 6, "sodium": 25, "cholesterol": 0, "calcium": 15, "iron": 0.7, "vitaminC": 5, "potassium": 600}', 
 349, '2024-01-01 00:00:00'),

('drink3', 'Plant-Based Protein Smoothie', 'GreenBlend', 'drinks', 'A', 'Organic smoothie with plant proteins, fruits, and vegetables. No artificial additives.', 
 '["Organic Pea Protein", "Organic Banana", "Organic Spinach", "Organic Almond Milk", "Organic Berries"]', 
 '{"calories": 150, "protein": 15, "carbs": 18, "fat": 3, "saturatedFat": 0.5, "transFat": 0, "fiber": 5, "sugar": 12, "sodium": 120, "cholesterol": 0, "calcium": 180, "iron": 2.8, "vitaminC": 25, "potassium": 420}', 
 499, '2024-01-01 00:00:00'),

('drink4', '100% Orange Juice', 'CitrusFresh', 'drinks', 'B', 'Pure orange juice with no added sugars. Pasteurized for safety.', 
 '["100% Orange Juice"]', 
 '{"calories": 110, "protein": 2, "carbs": 26, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 0, "sugar": 22, "sodium": 0, "cholesterol": 0, "calcium": 25, "iron": 0.5, "vitaminC": 124, "potassium": 450}', 
 449, '2024-01-01 00:00:00'),

('drink5', 'Flavored Sparkling Water', 'BubbleFresh', 'drinks', 'B', 'Sparkling water with natural fruit flavors. No calories or artificial sweeteners.', 
 '["Carbonated Water", "Natural Flavors"]', 
 '{"calories": 0, "protein": 0, "carbs": 0, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 0, "sugar": 0, "sodium": 5, "cholesterol": 0, "calcium": 0, "iron": 0, "vitaminC": 0, "potassium": 0}', 
 299, '2024-01-01 00:00:00'),

('drink6', 'Sports Drink', 'ElectroBoost', 'drinks', 'C', 'Electrolyte replacement drink with moderate sugar content and artificial colors.', 
 '["Water", "Sugar", "Dextrose", "Salt", "Potassium Chloride", "Artificial Flavors", "Artificial Colors"]', 
 '{"calories": 80, "protein": 0, "carbs": 21, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 0, "sugar": 21, "sodium": 160, "cholesterol": 0, "calcium": 0, "iron": 0, "vitaminC": 0, "potassium": 75}', 
 249, '2024-01-01 00:00:00'),

('drink7', 'Energy Drink', 'BuzzMax', 'drinks', 'D', 'High-caffeine energy drink with excessive sugar and artificial stimulants.', 
 '["Carbonated Water", "Sugar", "Caffeine", "Taurine", "Artificial Flavors", "Artificial Colors", "Preservatives"]', 
 '{"calories": 160, "protein": 0, "carbs": 39, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 0, "sugar": 37, "sodium": 200, "cholesterol": 0, "calcium": 0, "iron": 0, "vitaminC": 0, "potassium": 0}', 
 399, '2024-01-01 00:00:00'),

('drink8', 'Soda Cola', 'SugarFizz', 'drinks', 'E', 'High-sugar carbonated soft drink with artificial flavors, colors, and preservatives.', 
 '["Carbonated Water", "High Fructose Corn Syrup", "Caramel Color", "Phosphoric Acid", "Natural Flavors", "Caffeine"]', 
 '{"calories": 150, "protein": 0, "carbs": 39, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 0, "sugar": 39, "sodium": 45, "cholesterol": 0, "calcium": 0, "iron": 0, "vitaminC": 0, "potassium": 0}', 
 199, '2024-01-01 00:00:00'),

-- Additional Protein Powders
('protein6', 'Casein Protein', 'SlowRelease', 'protein_powder', 'A', 'Premium casein protein for nighttime recovery. Slow-digesting and high quality.', 
 '["Micellar Casein Protein", "Natural Vanilla", "Sunflower Lecithin"]', 
 '{"calories": 120, "protein": 28, "carbs": 2, "fat": 1, "saturatedFat": 0.5, "transFat": 0, "fiber": 0, "sugar": 1, "sodium": 60, "cholesterol": 15, "calcium": 150, "iron": 0.5, "vitaminC": 0, "potassium": 200}', 
 5499, '2024-01-01 00:00:00'),

('protein7', 'Collagen Protein', 'YouthBoost', 'protein_powder', 'B', 'Hydrolyzed collagen peptides for joint and skin health. Good bioavailability.', 
 '["Hydrolyzed Collagen Peptides", "Natural Flavors"]', 
 '{"calories": 70, "protein": 18, "carbs": 0, "fat": 0, "saturatedFat": 0, "transFat": 0, "fiber": 0, "sugar": 0, "sodium": 50, "cholesterol": 0, "calcium": 5, "iron": 0, "vitaminC": 50, "potassium": 0}', 
 3999, '2024-01-01 00:00:00'),

('protein8', 'Mass Gainer Protein', 'BulkUp', 'protein_powder', 'C', 'High-calorie protein blend for weight gain. Contains added carbs and fats.', 
 '["Whey Concentrate", "Maltodextrin", "Dextrose", "Creatine", "Artificial Flavors"]', 
 '{"calories": 380, "protein": 25, "carbs": 50, "fat": 8, "saturatedFat": 4, "transFat": 0, "fiber": 2, "sugar": 15, "sodium": 180, "cholesterol": 45, "calcium": 200, "iron": 6.3, "vitaminC": 60, "potassium": 400}', 
 3499, '2024-01-01 00:00:00'),

-- Additional Chips
('chips6', 'Baked Veggie Chips', 'GardenCrunch', 'chips', 'A', 'Baked vegetable chips made from real vegetables. No oil added.', 
 '["Sweet Potatoes", "Beets", "Carrots", "Sea Salt"]', 
 '{"calories": 110, "protein": 2, "carbs": 24, "fat": 0.5, "saturatedFat": 0, "transFat": 0, "fiber": 3, "sugar": 7, "sodium": 65, "cholesterol": 0, "calcium": 20, "iron": 0.5, "vitaminC": 8, "potassium": 290}', 
 459, '2024-01-01 00:00:00'),

('chips7', 'Plantain Chips', 'TropicalSnack', 'chips', 'B', 'Lightly salted plantain chips with coconut oil. Natural and crispy.', 
 '["Plantains", "Coconut Oil", "Sea Salt"]', 
 '{"calories": 150, "protein": 1, "carbs": 18, "fat": 8, "saturatedFat": 7, "transFat": 0, "fiber": 2, "sugar": 8, "sodium": 50, "cholesterol": 0, "calcium": 2, "iron": 0.3, "vitaminC": 11, "potassium": 260}', 
 379, '2024-01-01 00:00:00'),

('chips8', 'BBQ Flavored Chips', 'FlavorTown', 'chips', 'D', 'Heavily seasoned potato chips with BBQ flavoring and preservatives.', 
 '["Potatoes", "Vegetable Oil", "BBQ Seasoning", "Monosodium Glutamate", "Artificial Colors", "Natural and Artificial Flavors"]', 
 '{"calories": 170, "protein": 2, "carbs": 16, "fat": 11, "saturatedFat": 3, "transFat": 0.5, "fiber": 1, "sugar": 2, "sodium": 380, "cholesterol": 0, "calcium": 8, "iron": 0.4, "vitaminC": 6, "potassium": 140}', 
 189, '2024-01-01 00:00:00'),

-- Additional Chocolates
('chocolate6', 'Stevia Dark Chocolate', 'SweetLeaf', 'chocolates', 'A', 'Sugar-free dark chocolate sweetened with stevia. 80% cacao content.', 
 '["Organic Cacao", "Organic Cacao Butter", "Stevia Extract", "Vanilla"]', 
 '{"calories": 140, "protein": 3, "carbs": 8, "fat": 12, "saturatedFat": 7, "transFat": 0, "fiber": 4, "sugar": 0, "sodium": 0, "cholesterol": 0, "calcium": 20, "iron": 2.8, "vitaminC": 0, "potassium": 180}', 
 499, '2024-01-01 00:00:00'),

('chocolate7', 'White Chocolate', 'CreamyDelight', 'chocolates', 'D', 'White chocolate bar with high sugar and saturated fat content.', 
 '["Sugar", "Cocoa Butter", "Milk Powder", "Vanilla", "Soy Lecithin"]', 
 '{"calories": 240, "protein": 2, "carbs": 26, "fat": 14, "saturatedFat": 9, "transFat": 0, "fiber": 0, "sugar": 24, "sodium": 40, "cholesterol": 10, "calcium": 80, "iron": 0.2, "vitaminC": 0, "potassium": 120}', 
 229, '2024-01-01 00:00:00'),

('chocolate8', 'Protein Chocolate Bar', 'FitChoco', 'chocolates', 'B', 'Chocolate bar fortified with whey protein. Moderate sugar content.', 
 '["Dark Chocolate", "Whey Protein", "Almonds", "Natural Sweeteners"]', 
 '{"calories": 190, "protein": 12, "carbs": 18, "fat": 9, "saturatedFat": 4, "transFat": 0, "fiber": 3, "sugar": 12, "sodium": 45, "cholesterol": 5, "calcium": 120, "iron": 1.8, "vitaminC": 0, "potassium": 200}', 
 349, '2024-01-01 00:00:00'),

-- Additional Popcorn
('popcorn5', 'Nutritional Yeast Popcorn', 'CheesyGood', 'popcorn', 'A', 'Air-popped popcorn with nutritional yeast for cheesy flavor. Vegan-friendly.', 
 '["Organic Popcorn", "Nutritional Yeast", "Olive Oil", "Sea Salt"]', 
 '{"calories": 45, "protein": 3, "carbs": 6, "fat": 1.5, "saturatedFat": 0, "transFat": 0, "fiber": 1, "sugar": 0, "sodium": 15, "cholesterol": 0, "calcium": 5, "iron": 0.3, "vitaminC": 0, "potassium": 40}', 
 399, '2024-01-01 00:00:00'),

('popcorn6', 'Caramel Corn', 'SweetKernel', 'popcorn', 'D', 'Popcorn coated in caramel with high sugar content and artificial flavors.', 
 '["Popcorn", "Corn Syrup", "Brown Sugar", "Butter", "Artificial Caramel Flavor", "Preservatives"]', 
 '{"calories": 90, "protein": 1, "carbs": 18, "fat": 2, "saturatedFat": 1, "transFat": 0, "fiber": 1, "sugar": 12, "sodium": 65, "cholesterol": 2, "calcium": 5, "iron": 0.2, "vitaminC": 0, "potassium": 25}', 
 199, '2024-01-01 00:00:00'),

-- Additional Biscuits
('biscuit6', 'Almond Flour Cookies', 'NutriCrumb', 'biscuits', 'A', 'Gluten-free cookies made with almond flour and coconut sugar. Low glycemic.', 
 '["Almond Flour", "Coconut Sugar", "Coconut Oil", "Vanilla Extract", "Sea Salt"]', 
 '{"calories": 130, "protein": 5, "carbs": 10, "fat": 9, "saturatedFat": 3, "transFat": 0, "fiber": 3, "sugar": 6, "sodium": 45, "cholesterol": 0, "calcium": 60, "iron": 1, "vitaminC": 0, "potassium": 180}', 
 479, '2024-01-01 00:00:00'),

('biscuit7', 'Graham Crackers', 'CampfireClassic', 'biscuits', 'C', 'Traditional graham crackers with moderate sugar and whole wheat flour.', 
 '["Whole Wheat Flour", "Sugar", "Vegetable Oil", "Honey", "Cinnamon", "Salt"]', 
 '{"calories": 140, "protein": 2, "carbs": 24, "fat": 4, "saturatedFat": 1, "transFat": 0, "fiber": 2, "sugar": 8, "sodium": 160, "cholesterol": 0, "calcium": 15, "iron": 1.1, "vitaminC": 0, "potassium": 75}', 
 259, '2024-01-01 00:00:00'),

('biscuit8', 'Sandwich Cookies', 'CreamFilled', 'biscuits', 'E', 'Processed sandwich cookies with cream filling, high sugar, and trans fats.', 
 '["Enriched Flour", "Sugar", "Palm Oil", "High Fructose Corn Syrup", "Cocoa", "Artificial Flavors", "Preservatives"]', 
 '{"calories": 160, "protein": 2, "carbs": 25, "fat": 7, "saturatedFat": 2, "transFat": 1.5, "fiber": 1, "sugar": 14, "sodium": 135, "cholesterol": 0, "calcium": 10, "iron": 1, "vitaminC": 0, "potassium": 40}', 
 179, '2024-01-01 00:00:00')

ON DUPLICATE KEY UPDATE 
    name = VALUES(name),
    brand = VALUES(brand),
    category = VALUES(category),
    rating = VALUES(rating),
    description = VALUES(description),
    ingredients = VALUES(ingredients),
    nutrition_facts = VALUES(nutrition_facts),
    price = VALUES(price);
