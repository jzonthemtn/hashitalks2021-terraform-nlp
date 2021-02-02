#!/bin/bash
mvn clean package -f ./lambda-handler/pom.xml -DskipTests=true
