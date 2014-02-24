#!/bin/sh

# Starts Sidekiq workers from WAR file.
# Based in part on code from: https://github.com/jkutner/warbler-exec

WAR_FILE=sidekiq-demo.war
DEPLOY_DIR=deploy

mkdir -p ${DEPLOY_DIR}
rm -rf ${DEPLOY_DIR}/*

cd ${DEPLOY_DIR}
echo "Extracting WAR file contents to directory: ${DEPLOY_DIR}"
jar xf ../${WAR_FILE} 

cd WEB-INF
echo "Expanded application directory is `pwd`"

export CLASSPATH=`ls lib/*.jar | xargs | sed  's/ /\:/g'`
export GEM_PATH="./gems"
export GEM_HOME="./gems"

JRUBY_CMD="/usr/bin/java -Xmx512m -cp $CLASSPATH org.jruby.Main"
SIDEKIQ_CMD="${JRUBY_CMD} -S bin/sidekiq -r ./lib/workers.rb -vvv"

echo "Please wait: Starting sidekiq workers..."
${SIDEKIQ_CMD}
