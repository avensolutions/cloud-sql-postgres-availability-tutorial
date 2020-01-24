#
# main.tf - Cloud SQL Availability Tutorial for PostgreSQL
# 

provider "google" {
  region 	= var.region
  project	= var.project
}

provider "google-beta" {
  region = var.region
  zone   = var.zone
  project	= var.project
}

data "google_project" "project" {}

# generate random password for db user

resource "random_id" "db_password" {
  byte_length = 8
}

# Note: You cannot re-use an instance name for up to two months after deleting that instance, to get around this a random suffix is added to the instance name.

resource "random_id" "instance_suffix" {
  byte_length = 4
}

# create a custom mode VPC (used to deploy Compute Engine VM instance to be used as database clients)

resource "google_compute_network" "private_network" {
  name = "private-network"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}

# create a regional subnet to deploy Compute Engine VM Instances
resource "google_compute_subnetwork" "regional_subnet" {
  name          = "regional-subnet"
  ip_cidr_range = var.primary_ip_range
  region        = var.region
  network       = google_compute_network.private_network.self_link
  secondary_ip_range {
    range_name    = "secondary-range"
    ip_cidr_range = var.secondary_ip_range
  }
}

# create service networking config for private Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# create master private Cloud SQL instance with HA
resource "google_sql_database_instance" "postgres_master" {
  provider = google-beta
  region = var.region
  project			= var.project
  name = "postgresql-master-${random_id.instance_suffix.hex}"
  database_version = "POSTGRES_9_6"
  settings {
    tier 	= var.tier
    disk_size 					= var.disk_size
	  activation_policy 			= "ALWAYS"
	  disk_autoresize 			= true
	  disk_type 					= "PD_SSD"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled 				= true
      start_time 				= "00:00"
    }
    ip_configuration  {
      ipv4_enabled 			= false
      private_network = google_compute_network.private_network.self_link
    }
    maintenance_window  {
      day 					= 7
      hour 					= 0
      update_track 			= "stable"
    }
    location_preference {
      zone = var.masterZone
    }
  }
  depends_on = [google_service_networking_connection.private_vpc_connection]
} 

# create database

resource "google_sql_database" "test_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_master.name
}

# create user

resource "google_sql_user" "postgres_user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres_master.name
  password = random_id.db_password.hex
}

# create a read replica in a different zone to the master
resource "google_sql_database_instance" "postgres_replica" {
  provider = google-beta
  region = var.region
  project			= var.project
  name = "postgresql-replica-${random_id.instance_suffix.hex}"
  database_version = "POSTGRES_9_6"
  master_instance_name = google_sql_database_instance.postgres_master.name
  settings {
    tier 	= var.tier
    disk_size 					= var.disk_size
	  activation_policy 			= "ALWAYS"
	  disk_autoresize 			= true
	  disk_type 					= "PD_SSD"
    ip_configuration  {
      ipv4_enabled 			= false
      private_network = google_compute_network.private_network.self_link
    }
    location_preference {
       zone = var.replicaZone
    }
  }
}
