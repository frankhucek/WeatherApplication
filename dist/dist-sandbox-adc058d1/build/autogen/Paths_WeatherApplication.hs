module Paths_WeatherApplication (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/frank/Documents/Haskell/WeatherApplication/.cabal-sandbox/bin"
libdir     = "/home/frank/Documents/Haskell/WeatherApplication/.cabal-sandbox/lib/x86_64-linux-ghc-7.10.2/WeatherApplication-0.1.0.0-GezC0zemEkQICLS9cDv945"
datadir    = "/home/frank/Documents/Haskell/WeatherApplication/.cabal-sandbox/share/x86_64-linux-ghc-7.10.2/WeatherApplication-0.1.0.0"
libexecdir = "/home/frank/Documents/Haskell/WeatherApplication/.cabal-sandbox/libexec"
sysconfdir = "/home/frank/Documents/Haskell/WeatherApplication/.cabal-sandbox/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "WeatherApplication_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "WeatherApplication_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "WeatherApplication_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "WeatherApplication_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "WeatherApplication_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
