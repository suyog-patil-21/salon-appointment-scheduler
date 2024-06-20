#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?"

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

MAIN_MENU(){
    if [[ ! -z $1 ]]
    then 
        echo -e "\n$1"
    fi

    LIST_OF_SERVICE=$($PSQL "SELECT * FROM services ORDER BY service_id")
    SERVICE_LENGTH=$( echo "$LIST_OF_SERVICE" | wc -l)
    if [[ -z $LIST_OF_SERVICE ]]
    then
        MAIN_MENU "Sorry! No Services At the moment."  
    else 
        echo -e "$(echo "\n$LIST_OF_SERVICE" | sed 's/|/) /')"
        read SERVICE_ID_SELECTED

        if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
        then 
            MAIN_MENU "I could not find that service. What would you like today?"
        else
            if [[ $SERVICE_ID_SELECTED -gt 0 && $SERVICE_ID_SELECTED -le $SERVICE_LENGTH ]]
            then
                echo -e "\nWhat's your phone number?"
                read CUSTOMER_PHONE
                CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
                # if customer doesn't exist
                if [[ -z $CUSTOMER_NAME ]]
                then
                    # get new customer name
                    echo -e "\nI don't have a record for that phone number, what's your name?"
                    read CUSTOMER_NAME
                    # insert new customer
                    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
                fi
                
                CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
                SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
                
                echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
                read SERVICE_TIME
                
                INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id,customer_id,time) VALUES ($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")
                if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
                then
                    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
                fi
            else
                MAIN_MENU "I could not find that service. What would you like today?"
            fi
        fi
    fi
}


MAIN_MENU
