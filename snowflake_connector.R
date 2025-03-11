options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx8192m"))
gc()

library(rJava)
library(RJDBC)
library(DBI)

drv <- JDBC(
  driverClass = "net.snowflake.client.jdbc.SnowflakeDriver",
  classPath = "~/Documents/snowflake-jdbc-3.9.2.jar"
)

conn <- dbConnect(
  drv,
  url = "jdbc:snowflake://<your_account>.snowflakecomputing.com?CLIENT_SESSION_KEEP_ALIVE=true",  # Replace <your_account> with your Snowflake account URL
  user = "<your_username>",
  database = "<your_database>",
  warehouse = "<your_warehouse>",
  role = "<your_role>",
  authenticator = "externalBrowser"
)

rJava:::.jinit()
