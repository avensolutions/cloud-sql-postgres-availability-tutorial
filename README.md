# Google Cloud SQL PostgreSQL Availability Tutorial

This module is used to deploy a private Cloud SQL master instance with High Availability and a Read Replica instance  

See [Google Cloud SQL – Availability for PostgreSQL – Part II (Read Replicas)](https://www.cloudywithachanceofbigdata.com/google-cloud-sql-availability-for-postgresql-part-ii-read-replicas/) and [Google Cloud SQL – Availability, Replication, Failover for PostgreSQL – Part I](https://www.cloudywithachanceofbigdata.com/google-cloud-sql-ha-backup-and-recovery-replication-failover-and-security-for-postgresql-part-i/)  

Run the following code in Powershell (using Terraform) to deploy:
```powershell
PS >.\deploy_infra.ps1 apply
```
> Requires the [Service Networking API](https://console.developers.google.com/apis/api/servicenetworking.googleapis.com/overview) to be enabled for your Google Project

