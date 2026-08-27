<?php

if (!function_exists('getenv_docker')) {
    // https://github.com/docker-library/wordpress/issues/588 (WP-CLI will load this file 2x)
    function getenv_docker($env, $default)
    {
        if ($fileEnv = getenv($env . '_FILE')) {
            return rtrim(file_get_contents($fileEnv), "\r\n");
        } elseif (($val = getenv($env)) !== false) {
            return $val;
        }

        return $default;
    }
}

define('DB_NAME', getenv_docker('WORDPRESS_DB_NAME', 'wordpress'));
define('DB_USER', getenv_docker('WORDPRESS_DB_USER', 'wordpress'));
define('DB_PASSWORD', getenv_docker('WORDPRESS_DB_PASSWORD', 'wordpress'));
define('DB_HOST', getenv_docker('WORDPRESS_DB_HOST', 'db'));
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY',         'x7kP2mQ9vL4nR8wT1jH6cF0bY3sA5dG=uE');
define('SECURE_AUTH_KEY',  'pB4hN0zK8mW2qX6tJ9cV1rL5fD7yS3aU#i');
define('LOGGED_IN_KEY',    'gM6sC1vP9nH3kR7wQ2jT8bF4dY0eA5lZ@o');
define('NONCE_KEY',        'uD8fL2xK5pN9mW1qT6cH0rJ4vB7yS3aI$e');
define('AUTH_SALT',        'cR5tY1hG8nM2kP6wQ9jV3bF0dL4sA7eX%u');
define('SECURE_AUTH_SALT', 'wJ0qT4mN7pH2kR8cF1vL5bY9dS3aG6eZ^i');
define('LOGGED_IN_SALT',   'nF3bV6sK9mW1qP8tH0rJ4cD7yL2aX5eU&o');
define('NONCE_SALT',       'kH7cP0nM4wQ2jT9vL5bF1dY8sA3eR6gZ*i');

$table_prefix = 'wp_';

define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

$project = getenv_docker('PROJECT_NAME', 'my-project');
define('WP_HOME', 'https://local.' . $project . '.dev');
define('WP_SITEURL', 'https://local.' . $project . '.dev');

define('FORCE_SSL_ADMIN', true);

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
    $_SERVER['HTTPS'] = 'on';
}

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
