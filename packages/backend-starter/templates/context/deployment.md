# Deployment Guidelines

## Pre-Deployment Checklist

- [ ] All tests pass
- [ ] Environment variables configured
- [ ] Database migrations reviewed
- [ ] Backup current database
- [ ] Review code changes
- [ ] Check dependencies are up to date
- [ ] Test on staging environment
- [ ] Review security settings
- [ ] Check disk space
- [ ] Document deployment process

## Environment Configuration

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:random-key

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=production_db
DB_USERNAME=prod_user
DB_PASSWORD=secure_password

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

## Deployment Steps

### 1. Preparation

```bash
# Pull latest code
git pull origin main

# Install dependencies
composer install --no-dev --optimize-autoloader
npm ci --production
```

### 2. Build Assets

```bash
# Compile assets
npm run production

# Clear old compiled files
php artisan view:clear
php artisan config:clear
php artisan route:clear
```

### 3. Database Migration

```bash
# Backup database first!
php artisan backup:run --only-db

# Run migrations
php artisan migrate --force

# Seed if necessary
php artisan db:seed --class=ProductionSeeder
```

### 4. Optimization

```bash
# Cache configuration
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache views
php artisan view:cache

# Optimize autoloader
composer dump-autoload --optimize
```

### 5. Queue & Scheduler

```bash
# Restart queue workers
php artisan queue:restart

# Verify scheduler cron job
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

## Zero-Downtime Deployment

### Using Deployer or Envoyer

- Deploy to new release directory
- Symlink current to new release
- Maintain shared folders (storage, .env)
- Keep previous releases for rollback

### Laravel Forge

- Automated deployments from Git
- Zero-downtime deployment built-in
- Queue worker management
- SSL certificate management

## Server Requirements

### PHP Extensions

- BCMath
- Ctype
- Fileinfo
- JSON
- Mbstring
- OpenSSL
- PDO
- Tokenizer
- XML
- cURL
- GD or Imagick (for image processing)

### Web Server Configuration

#### Nginx

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## Performance Optimization

- Enable OPcache
- Use Redis for cache and sessions
- Configure queue workers
- Optimize database queries
- Use CDN for assets
- Enable gzip compression
- Set proper cache headers

## Monitoring

- Set up error tracking (Sentry, Bugsnag)
- Monitor server resources
- Track application performance
- Log critical operations
- Set up uptime monitoring
- Monitor queue workers

## Backup Strategy

```bash
# Automated backups
php artisan backup:run

# Backup database
mysqldump -u user -p database > backup.sql

# Backup files
tar -czf storage-backup.tar.gz storage/
```

## Rollback Process

1. Revert to previous Git commit
2. Restore database backup if needed
3. Run necessary migrations (down)
4. Clear caches
5. Restart workers

## CI/CD Pipeline

```yaml
# Example GitHub Actions
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: php artisan test
      - name: Deploy to production
        run: ./deploy.sh
```

## Security Considerations

- Disable debug mode in production
- Use HTTPS everywhere
- Set proper file permissions (755 for directories, 644 for files)
- Keep `.env` outside webroot
- Regular security updates
- Implement rate limiting
- Use firewall rules

## Post-Deployment

- Verify application is running
- Check logs for errors
- Test critical user flows
- Monitor performance metrics
- Notify team of successful deployment

---

_This is a starter template. Customize based on your project needs._
