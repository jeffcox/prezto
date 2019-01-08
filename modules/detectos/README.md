detect OS
=========

This is a custom module to detect which OS the user is on and load the appropriate modules.

The use case here is pretty limited, but it will save me the trouble of stashing and dropping.

The same logic that validates the initial load (checking $OSTYPE) for osx and freebsd will be used.

I'm considering loading dpkg or dnf based on distro but don't want to bog load time down any further.
