#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  CONDITION="e.atomic_number = $1"
else
  CONDITION="e.symbol ILIKE '$1' OR e.name ILIKE '$1'"
fi

QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e 
JOIN properties p ON e.atomic_number = p.atomic_number 
JOIN types t ON p.type_id = t.type_id 
WHERE $CONDITION;"

RESULT=$($PSQL "$QUERY")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
  do
    CLEAN_NUMBER=$(echo "$ATOMIC_NUMBER" | xargs)
    CLEAN_NAME=$(echo "$NAME" | xargs)
    CLEAN_SYMBOL=$(echo "$SYMBOL" | xargs)
    CLEAN_TYPE=$(echo "$TYPE" | xargs)
    CLEAN_MASS=$(echo "$MASS" | xargs)
    CLEAN_MELTING=$(echo "$MELTING" | xargs)
    CLEAN_BOILING=$(echo "$BOILING" | xargs)

    echo -n "The element with atomic number $CLEAN_NUMBER is $CLEAN_NAME ($CLEAN_SYMBOL). It's a $CLEAN_TYPE, with a mass of $CLEAN_MASS amu. $CLEAN_NAME has a melting point of $CLEAN_MELTING celsius and a boiling point of $CLEAN_BOILING celsius."
  done
fi
