#!/bin/bash

# Load API key from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

API_KEY=${GOOGLE_API_KEY:-$GEMINI_API_KEY}

if [ -z "$API_KEY" ]; then
    echo "❌ No API key found in .env file (looking for GOOGLE_API_KEY or GEMINI_API_KEY)"
    exit 1
fi

echo "Testing Gemini API with key: ${API_KEY:0:5}..."

curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$API_KEY" \
    -H 'Content-Type: application/json' \
    -d '{
      "contents": [{
        "parts": [{"text": "Hello, are you working?"}]
      }]
    }' > api_test_result.json

if grep -q "text" api_test_result.json; then
    echo "✅ API Success! Response received."
    cat api_test_result.json
else
    echo "❌ API Failed."
    cat api_test_result.json
fi

