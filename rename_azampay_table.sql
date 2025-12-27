-- Rename the existing table to match the model configuration
RENAME TABLE azam_pay_transactions TO azampay_transactions;

-- Verify the table was renamed
SELECT 'Table renamed successfully' as status;