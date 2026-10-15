CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    state VARCHAR(100)
);

INSERT INTO customers (customer_id, first_name, state)
VALUES
(1, 'Avijit', 'West Bengal'),
(2, 'Rahul', 'Maharashtra'),
(3, 'Priya', 'Karnataka'),
(4, 'Amit', 'Delhi'),
(5, 'Sneha', 'Tamil Nadu'),
(6, 'Rohan', 'Gujarat'),
(7, 'Ananya', 'Rajasthan'),
(8, 'Vikash', 'Bihar'),
(9, 'Neha', 'Uttar Pradesh'),
(10, 'Arjun', 'Kerala');