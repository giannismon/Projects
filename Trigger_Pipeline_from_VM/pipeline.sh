#!/bin/bash
# ====== CONFIG ======
AZDO_PAT="<YOUR_AZURE_DEVOPS_PAT>"
ORG="<YOUR_ORGANIZATION>"
PROJECT="<YOUR_PROJECT>"
PIPELINE_ID="<YOUR_PIPELINE_ID>"
BRANCH="<YOUR_BRANCH>"

echo "Triggering pipeline $PIPELINE_ID on branch $BRANCH..."
curl -u :$AZDO_PAT \
     -X POST \
     -H "Content-Type: application/json" \
     "https://dev.azure.com/$ORG/$PROJECT/_apis/pipelines/$PIPELINE_ID/runs?api-version=7.1" \
     -d '{
           "resources": {
             "repositories": {
               "self": {
                 "refName": "refs/heads/'"$BRANCH"'"
               }
             }
           }
         }'
echo ""
echo "Pipeline triggered on $BRANCH!"
