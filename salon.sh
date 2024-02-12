#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to my salon, how can I help you?\n"
$PSQL "SELECT service_id, name FROM services;" | while IFS='|' read -r ID NAME
do
  echo "$ID) $NAME"
done

read SERVICE_ID_SELECTED

# Fetch the service_id from the database. The query is now properly quoted.
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

# Check if SERVICE_ID is empty. If it is, list all services.
if [[ -z $SERVICE_ID ]]; then
  echo "Service ID not found. Listing all services:"
  $PSQL "SELECT service_id, name FROM services;" | while IFS='|' read -r ID NAME
  do
    echo "$ID) $NAME"
  done
else
  # If service id found, echo it
  echo "Service ID found: $SERVICE_ID"
#save the service  
SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID';") 
  # Ask for the phone number

  echo -e "\nPlease enter your phone number:\n"
  read CUSTOMER_PHONE
  
  # Search for customer
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  
  # Check if customer exists
  if [[ -z $CUSTOMER_NAME ]]; then
    # If phone number not found
  echo -e "\nPlease enter your name\n"
    read CUSTOMER_NAME
    
    # Insert new customer into table. Ensure proper quoting and command execution.
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    
    echo "\nYou have been added to our customer list.\n"
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME';") 
   echo -e "\nAt which time would you like to come, $CUSTOMER_NAME?\n"
  read SERVICE_TIME

  INSERT_SERVICE_AND_DATE=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID', '$SERVICE_TIME');")
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
fi
