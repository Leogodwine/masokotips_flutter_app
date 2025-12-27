-- Create the azampay_transactions table based on migration
CREATE TABLE `azampay_transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subscription_id` bigint(20) unsigned NOT NULL,
  `external_id` varchar(255) NOT NULL,
  `azampay_transaction_id` varchar(255) DEFAULT NULL,
  `azampay_payment_id` varchar(255) DEFAULT NULL,
  `service_code` varchar(255) NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'TZS',
  `status` enum('pending','completed','failed') NOT NULL DEFAULT 'pending',
  `azampay_status` varchar(255) DEFAULT NULL,
  `callback_data` json DEFAULT NULL,
  `initiated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL,
  `failed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `azampay_transactions_external_id_unique` (`external_id`),
  KEY `azampay_transactions_subscription_id_foreign` (`subscription_id`),
  KEY `azampay_transactions_azampay_transaction_id_index` (`azampay_transaction_id`),
  KEY `azampay_transactions_status_index` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key constraint
ALTER TABLE `azampay_transactions` 
ADD CONSTRAINT `azampay_transactions_subscription_id_foreign` 
FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`) ON DELETE CASCADE;