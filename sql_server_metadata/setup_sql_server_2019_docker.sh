###
# Setup script for fetching, building, starting & loading example data into a Dockerized version of SQl Server
###

# Get the container from Dockerhub
docker pull mcr.microsoft.com/mssql/server:2019-latest

# Set a password to use
USER_PASSWORD=YourStrong@Passw0rd

# start it UP, bound to port 1433
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$USER_PASSWORD" \
   -p 1433:1433 --name sql1 \
   -d mcr.microsoft.com/mssql/server:2019-latest

# check that its all running
docker ps -a

# connect and open up sql command line via interactive bash
docker exec -it sql1 "bash"

# then start the server it
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$USER_PASSWORD"

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

# Find IP address of running container (whre container id is int herE)
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




# https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15
# https://stackoverflow.com/questions/887370/sql-server-extract-table-meta-data-description-fields-and-their-data-types
# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&pivots=cs1-bash
# Rsources: https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15
