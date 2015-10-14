{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module GeoLocation where

import            Data.Aeson
import            Data.Aeson.Types
import            Network.HTTP.Client
import            Network.HTTP.Client.TLS
import            Text.Regex.Posix
import            Data.List.Split

import            GHC.Generics
import qualified  Data.ByteString.Lazy.Char8 as B


data GeoReq = GeoReq { wifiAPs :: [AccessPoint] } deriving (Show, Generic)

data AccessPoint = AccessPoint { address :: String } deriving (Show, Generic)

data GeoResp = GeoResp { location :: Location
                       , accuracy :: Float
                       } deriving (Show, Generic)

data Location = Location { lat :: Float
                         , lng :: Float
                         } deriving (Show, Generic)

-- let the compiler do these
instance FromJSON Location
instance FromJSON GeoReq
instance FromJSON GeoResp
instance FromJSON AccessPoint
instance ToJSON Location
instance ToJSON GeoReq
instance ToJSON GeoResp
instance ToJSON AccessPoint


testReq :: IO (Maybe Location)
testReq = do

  manager <- newManager tlsManagerSettings

  -- get Google api key to get latitude/longitude
  latlongKey <- readFile "/home/frank/Documents/Haskell/WeatherApplication/GoogleLocationKey.txt"
  -- Create the request
  initialRequest <- parseUrl $ "https://www.googleapis.com/geolocation/v1/geolocate?key=" ++ latlongKey
  let request = initialRequest { method = "POST", requestBody = RequestBodyLBS $ encode req }
  response <- httpLbs request manager
  --  putStrLn $ "The status code was: " ++ (show $ statusCode $ responseStatus response)

  let b = responseBody response
  -- print $ responseBody response
  let gsp = decode b :: Maybe GeoResp
  case gsp of
   Nothing -> return Nothing
   Just r -> return $ Just $ location r
  where body = B.unpack $ encode $ req
        req = GeoReq [AccessPoint addr]
        addr = "" -- "00:00:0c:07:ac:2c"

lookupLatLong :: (Maybe Location) -> IO (String, String)
lookupLatLong l = case l of
  Nothing -> print "what" >> return ("","")
  Just loc -> do
    let lt = lat loc
        lg = lng loc
    manager <- newManager tlsManagerSettings

    locationKey <- readFile "/home/frank/Documents/Haskell/WeatherApplication/GoogleLatLongToCityKey.txt"

    request <- parseUrl $
               "https://maps.googleapis.com/maps/api/geocode/json?latlng=" ++ show lt ++ "," ++ show lg ++ "&location_type=approximate&result_type=locality&key" ++ locationKey
    response <- httpLbs request manager
    let res = B.unpack $ responseBody response

    -- formatting mess. will be cleaned up
    let res' = getAllTextMatches $ res =~ ("\"formatted_address\" : .*$" :: String) :: [String]
        res'' = head $ tail $ splitOn ":" $ head res'
        res''' = reverse $ dropWhile (\c -> c == '"' || c == ' ' || c == ',') $ reverse $ dropWhile (\c -> c == '"' || c == ' ' || c == ',') $ res''
        res'''' = (\(x:y:[]) -> (x,y)) $ take 2 $ splitOn ", " res'''

    -- print res''''
    return $ res''''
