#! /bin/bash

    PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

    echo -e "\n~~~~~ MY SALON ~~~~~\n"

    

    MAIN_MENU() {
    

    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    echo -e "Welcome to My Salon, how can I help you?\n"
    #get the service list names and id's
    SERVICES_LIST=$($PSQL "SELECT * FROM services")


    #output the service list and their ids
    echo "$SERVICES_LIST"  | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo -e "$SERVICE_ID) $SERVICE_NAME"
    done 

    #get the user input
    read SERVICE_ID_SELECTED

    #check if the user input in a number
   : ' if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        MAIN_MENU "This is not a valid Service Number. Please select a valid number for the service list"
    fi'

    #check if the user input is provided
    SELECTED_SERVCE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    #if the service is npt provided
    if [[ -z $SELECTED_SERVCE_RESULT ]]
    then
        MAIN_MENU "I could not find that service. What would you like today?"
    #if the service is provided 
    else
        #get the service name
        SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        echo -e "\nYou have chosen to do the $SELECTED_SERVICE_NAME today.\n"
        
        #get the user phone number
        echo -e "What's your phone number?"
        read CUSTOMER_PHONE

        #check if the user phone number is in the database
        CUSTOMER_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

        #if the user phone number is not in the database
        if [[ -z $CUSTOMER_PHONE_RESULT ]]
        then

        #take the user (new customer) name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        #add the new customer name, phone
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")

        else
        #get the customer name from the database
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        fi
        #take the time for when the user wants to have his service
        echo -e "\nWhat time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        

        #we need to add a new appointment so we need to get the customer_id 
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        #add a new appointment
        ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

        echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."


        
    fi
    }

    
  MAIN_MENU