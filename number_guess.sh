#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"

echo "Enter your username:"
read USERNAME
USERNAME_RESULT=$($PSQL "INSERT INTO records(username, games_played) VALUES('$USERNAME', 0)" 2> /dev/null)
if [[ $USERNAME_RESULT == "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM records WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM records WHERE username='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET=$(( ( RANDOM % 1000 )  + 1 ))

echo "Guess the secret number between 1 and 1000:"
echo Secret number is $SECRET
GUESS_COUNT=1

while [[ $GUESS -ne $SECRET ]]
do
read GUESS
if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  else
    case $GUESS in
    $SECRET) echo You guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job! 
    GAMES_PLAYED_RESULT=$($PSQL "UPDATE records SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME'")
    if [[ -z $BEST_GAME ]] || [[ $GUESS_COUNT -lt $BEST_GAME ]]
      then
      ((BEST_GAME=GUESS_COUNT))
      BEST_GAME_RESULT=$($PSQL "UPDATE records SET best_game=$BEST_GAME WHERE username='$USERNAME'")
    fi
    break ;;
    *) ((GUESS_COUNT++)) ;;
    esac
    if [[ $GUESS -lt $SECRET ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
fi
done
