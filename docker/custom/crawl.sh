#!/bin/bash
echo -e "crawl -i --time-limit-fetch 10 -s ${NUTCH_HOME}/urls ${NUTCH_HOME}/crawl 10"
crawl -i --time-limit-fetch 10 -s $NUTCH_HOME/urls $NUTCH_HOME/crawl 10
