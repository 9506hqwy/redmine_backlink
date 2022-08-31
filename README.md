# Redmine Backlink

This plugin provides a backlink list against an inner link. 

## Features

View backlink list to bellow items.

- document
- issue
- issue's note
- forum, message
- news
- wiki

The backlink is on side bar in issue and wiki page, and on page bottom in other page.

## Installation

1. Download plugin in Redmine plugin directory.
   ```sh
   git clone https://github.com/9506hqwy/redmine_backlink.git
   ```
2. Install plugin in Redmine directory.
   ```sh
   bundle exec rake redmine:plugins:migrate NAME=redmine_backlink RAILS_ENV=production
   ```
3. Start Redmine

## Configuration

- Re-scan inner link text for creating the back link.
  ```sh
  bundle exec rake redmine_backlink:relink
  ```

## Tested Environment

* Redmine (Docker Image)
  * 3.4
  * 4.0
  * 4.1
  * 4.2
  * 5.0
* Database
  * SQLite
  * MySQL 5.7
  * PostgreSQL 12

## References

- [#8575 macro backlinks](https://www.redmine.org/issues/8575)
