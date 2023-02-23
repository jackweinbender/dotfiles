function jenv {
  export PATH=/Library/Java/JavaVirtualMachines/$ACTIVE_JAVA_VERSION/Contents/Home/bin:$PATH
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/$ACTIVE_JAVA_VERSION/Contents/Home
  
  echo "Set ACTIVE_JAVA_VERSION to $ACTIVE_JAVA_VERSION"
  java --version
}

function jenv_graalvm {
  export ACTIVE_JAVA_VERSION=graalvm-ce-java17-22.3.0
  jenv 
}

