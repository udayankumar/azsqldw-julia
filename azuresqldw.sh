# You can use the Azure CLI 2.0 docker container
# docker run azuresdk/azure-cli-python:latest

# Create Resource Group and Datawarehouse
LOCATION=YOUR_LOCATION #westeurope
RESOURCE_GROUP_NAME=YOUR_RESOURCE_GROUP
ADMIN_USER=YOUR_USER
ADMIN_PASSWORD=YOUR_PWD

# Note : This Script uses azure-cli (2.0.2) and sql (2.0.0) , you can check your version with az --version
# You can update your CLI with 
az component update

# Create Resource Group
az group create --location $LOCATION --name $RESOURCE_GROUP_NAME


# Create Azure SQL  Server
az sql server create --administrator-login-password $ADMIN_PASSWORD \
                     --administrator-login $ADMIN_USER \
                     --location $LOCATION \
                     --name $RESOURCE_GROUP_NAME \
                     --resource-group $RESOURCE_GROUP_NAME
# Get Public IP
MY_IP=$(curl ipinfo.io/ip)

# Create Firewall rule so you can connect from your IP
az sql server firewall create --end-ip-address $MY_IP \
                                   --start-ip-address $MY_IP \
                                   --resource-group $RESOURCE_GROUP_NAME \
                                   --server $RESOURCE_GROUP_NAME \
                                   --name "OFFICE01"



# Create Azure SQL DW , this will create a DW with 100 DWU
az sql dw create --name $RESOURCE_GROUP_NAME \
                 --resource-group $RESOURCE_GROUP_NAME \
                 --server $RESOURCE_GROUP_NAME
                 # [--collation COLLATION]
                 # [--max-size MAX_SIZE]
                 # [--service-objective SERVICE_OBJECTIVE]

# Get Connection String
                      
SQL_CONNECTRION_STRING=$( printf "Driver={ODBC Driver 13 for SQL Server};Server=tcp:%s.database.windows.net,1433;Database=%s;Uid=%s@%s;Pwd=%s;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;" \
                             "$RESOURCE_GROUP_NAME" \
                             "$RESOURCE_GROUP_NAME" \
                             "$ADMIN_USER" \
                             "$RESOURCE_GROUP_NAME" \
                             "$ADMIN_PASSWORD"  )

# Now we are ready to use the provided Julia & ODBC docker container
docker run -it -v $(pwd):/usr/azuresqljulia -e SQL_CONNECTION_STRING="${SQL_CONNECTRION_STRING}"  gonzaloruiz/azuresqljulia 

# Execute the following Commands while you are in the docker container
# Run the Julia Script
# julia /usr/azuresqljulia/azureodbc.jl "${SQL_CONNECTION_STRING}"