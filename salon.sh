#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_ID_SELECTED=""

LIST_SERVICES(){
  SERVICES=$($PSQL "SELECT * FROM services;")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nI could not find that service. What would you like today?\n"
    LIST_SERVICES
  fi

  HAVE_SERVICE=$($PSQL "SELECT * FROM services WHERE service_id='$SERVICE_ID_SELECTED';")
  if [[ -z $HAVE_SERVICE ]]
  then
    echo -e "\nI could not find that service. What would you like today?\n"
    LIST_SERVICES
  fi
}

LIST_SERVICES

MAIN_MENU(){

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
HAVE_NUMBER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")
if [[ -z $HAVE_NUMBER ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERTED_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
fi
CLIENT_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED';")
CLIENT_NAME_FORMATTED=$(echo $CLIENT_NAME | sed 's/ //g')
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')

echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CLIENT_NAME_FORMATTED?"
read SERVICE_TIME
FORMATTED_SERVICE_TIME=$(echo $SERVICE_TIME | sed 's/ //g')

CLIENT_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE';")
INSERTED_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CLIENT_ID', '$SERVICE_ID_SELECTED', '$FORMATTED_SERVICE_TIME');")
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $FORMATTED_SERVICE_TIME, $CLIENT_NAME_FORMATTED."

}

MAIN_MENU
