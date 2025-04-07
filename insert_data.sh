#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Wipe clean the data
echo $($PSQL "TRUNCATE games, teams")

# Skip the header row
cat games.csv | tail -n +2 | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Insert winner team if doesn't exist
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  if [[ -z $WINNER_ID ]]
  then
    # Insert team
    INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER == "INSERT 0 1" ]]
    then
      echo "Inserted team: $WINNER"
    fi
    # Get the new ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi

  # Insert opponent team if doesn't exist
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  if [[ -z $OPPONENT_ID ]]
  then
    # Insert team
    INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
    then
      echo "Inserted team: $OPPONENT"
    fi
    # Get the new ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  # Insert game data
  INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $W_GOALS, $O_GOALS)")
  if [[ $INSERT_GAME == "INSERT 0 1" ]]
  then
    echo "Inserted game: $YEAR $ROUND - $WINNER vs $OPPONENT"
  fi
done