{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

import         Net.Weather
import         UI.HSCurses.Curses
import         UI.HSCurses.CursesHelper
import         System.Exit
import         Control.Monad
import         Data.Maybe
import         Data.List
import         Data.List.Split

import         GeoLocation

main :: IO ()
main = do

  l <- testReq
  (c, state) <- lookupLatLong l

  -- have to format city
  let city = intercalate "%20" $ splitOn " " c

  wundergroundKey <- myAPIKey

  cond <- getConditions wundergroundKey city state -- myCity myState
  mainscr <- initScr
  --(x , y) <- scrSize -- line, column -- causing issues

  echo False
  keypad mainscr True
  --startColor
  --initPair (Pair 1) cyan black
  --attrSet attr0 $ Pair 1

  case cond of
   Nothing -> mvWAddStr mainscr 0 0 "No data for that city/state available"
   Just (Observation{..}) -> do
     mvWAddStr mainscr 0 0 $ "Weather for " ++ city ++ ", " ++ state
     mvWAddStr mainscr 1 0 $ "Conditions  -> " ++ getObsWeather (fromJust cond)
     mvWAddStr mainscr 2 0 $ "Temperature -> " ++ (show . getObsTemp $ fromJust cond) ++ " F"
     mvWAddStr mainscr 3 0 $ "Humidity    -> " ++ getObsHumidity (fromJust cond)
     mvWAddStr mainscr 4 0 $ "Wind        -> " ++ getObsWind (fromJust cond)
     mvWAddStr mainscr 5 0 $ "Feels like  -> " ++ getObsFeelsLike (fromJust cond)
     -- mvWAddStr mainscr 6 0 $ getObsTime $ fromJust cond

  mvWAddStr mainscr 7 0 "Press 'q' to quit..."
  refresh

  forever $ do
    c <- getCh
    if c == KeyChar 'q'
      then delWin mainscr >> endWin >> exitSuccess
      else do
        move 7 0
        clrToEol
        mvWAddStr mainscr 7 0 $ "Unknown input. Press 'q' to quit..."
        refresh

getObsTemp :: Observation -> Float
getObsTemp (Observation _ _ temp _ _ _) = temp

getObsHumidity :: Observation -> String
getObsHumidity (Observation _ _ _ h _ _) = h

getObsWind :: Observation -> String
getObsWind (Observation _ _ _ _ w _) = w

getObsFeelsLike :: Observation -> String
getObsFeelsLike (Observation _ _ _ _ _ f) = f

getObsWeather :: Observation -> String
getObsWeather (Observation _ w _ _ _ _) = w

getObsTime :: Observation -> [Char]
getObsTime (Observation t _ _ _ _ _) = t

-- sign up for key at wunderground.com
myAPIKey :: IO (String) -- from wunderground.com, 500 queries per day, 10 per minute
myAPIKey = do
  key <- readFile "/home/frank/Documents/Haskell/WeatherApplication/WundergroundKey.txt"
  return key

-- If Geolocation isn't working
myCity :: String
myCity = "Cleveland"

myState :: String
myState = "OH"
