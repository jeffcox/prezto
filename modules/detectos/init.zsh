# Detect the host OS and load appropriate zprezto modules
# This should be used in lieu of the specific modules in zpreztorc

# Conditional soup to emulate init.zsh for each OS
# This loads the necessary modules
if [[ "$OSTYPE" == freebsd* ]]; then
  source ${ZPREZTODIR}/modules/freebsd/init.zsh && zstyle ":prezto:module:freebsd" loaded 'yes'
elif [[ "$OSTYPE" == darwin* ]]; then
  source ${ZPREZTODIR}/modules/osx/init.zsh && zstyle ":prezto:module:osx" loaded 'yes'
  source ${ZPREZTODIR}/modules/macports/init.zsh && zstyle ":prezto:module:macports" loaded 'yes'
elif [[ "$OSTYPE" == linux-gnu ]]; then
  #ugh, linux, let's shotgun this bitch
  source ${ZPREZTODIR}/modules/dnf/init.zsh && zstyle ":prezto:module:dnf" loaded 'yes'
  source ${ZPREZTODIR}/modules/dpkg/init.zsh && zstyle ":prezto:module:dpkg" loaded 'yes'
  source ${ZPREZTODIR}/modules/yum/init.zsh && zstyle ":prezto:module:yum" loaded 'yes'
else
  echo "You've invoked the detectos module but it could not detect your OS"
  echo "Please configure zpreztorc manually.  Sorry."
fi
