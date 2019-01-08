# Detect the host OS and load appropriate zprezto modules
# This should be used in lieu of the specific modules in zpreztorc


# Modules are either loaded or have their state storied in zstyle.  zprezto init.zsh holds the secrets

if [[ "$OSTYPE" == freebsd* ]]; then
  return 1
elif [[ "$OSTYPE" == darwin* ]]; then
  return 1
elif [[ "$OSTYPE" == linux-gnu ]]; then
  return 1
else
  echo "You've invoked the detectos module but it could not detect your OS"
  echo "Please configure zpreztorc manually.  Sorry."
fi
