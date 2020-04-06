### Dockerized SQL Server Metadata Tableau example

This is an example of how to use Tableau and SQL Server to build an interactive data dictionary based purely on database metadata. This particular example uses SQL Server, but it is appliacble to any database type with some slight modifications to the metadata query.

In order to get my hands on some 'real' metadata, I build and run an example SQL Server 2019 instance locally via Docker. I have included all my setup scripts here, but also the data itself, in case you don't feel like following a Docker setup.

Some resources I was following to build this example include:
* SQL Server Docker install guide: https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&pivots=cs1-bash
* Some reminders on the exact metadata query: https://stackoverflow.com/questions/887370/sql-server-extract-table-meta-data-description-fields-and-their-data-types
* The 'Adventure Works' demo data: https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15
