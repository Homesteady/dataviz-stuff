###
# Setup script for SQL Server 2019 in Docker
# This will build the database, start it up, and load up example data
###

# Get the MSSQL 2019 image from Dockerhub
docker pull mcr.microsoft.com/mssql/server:2019-latest

# Set a password to use for this database (note: change me!)
USER_PASSWORD=YourStrong@Passw0rd

# Create the MSSQL container and run it, bound to port 1433
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$USER_PASSWORD" \
   -p 1433:1433 --name sql1 \
   -d mcr.microsoft.com/mssql/server:2019-latest

# Check that the container is running (should see 'sql1' status as Up)
docker ps

# Connect to the running container and open up sql command line via interactive bash
docker exec -it sql1 "bash"

# Finally, start up the database itself
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P YourStrong@Passw0rd



# worked?
CREATE DATABASE TestDB
SELECT Name from sys.Databases
GO

USE TestDB 
CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT)
INSERT INTO Inventory VALUES (1, 'banana', 150); INSERT INTO Inventory VALUES (2, 'orange', 154);
GO

SELECT * FROM Inventory WHERE quantity > 152;
GO

QUIT

# Find IP address of running container (where the container id is int herE)
docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker container ls -q --filter name="sql1")


USE [TestDB] RESTORE DATABASE [AdventureWorks2017] FROM 
DISK = '/Users/Andy_iMac/Downloads/AdventureWorks2017.bak' WITH FILE = 1, NOUNLOAD, REPLACE, STATS = 10
;

sudo docker cp WideWorldImportersDW-Full.bak sql_server_demo:/var/opt/mssql/backup

RESTORE FILELISTONLY
FROM DISK = '/var/opt/mssql/backup/AdventureWorks2017.bak'
GO


docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "$USER_PASSWORD" \
   -Q 'RESTORE DATABASE AdventureWorks2017 FROM DISK = "/var/opt/mssql/backup/AdventureWorks2017.bak" WITH MOVE "AdventureWorks2017_log" TO "/var/opt/mssql/data/AdventureWorks2017_log.ldf", MOVE "AdventureWorks2017" TO "/var/opt/mssql/data/AdventureWorks2017"'
