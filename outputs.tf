# connection name
output "master_connection_name" {
  value = google_sql_database_instance.postgres_master.connection_name
}

output "replica_connection_name" {
  value = google_sql_database_instance.postgres_replica.connection_name
}

# password
output "db_password" {
  value = random_id.db_password.hex
}
 