

curl "http://localhost:8001/abc/def?name=Alice&age=30"

curl -X POST http://localhost:8001/ \
  -H "Content-Type: application/json" \
  -d '{"product": "laptop", "price": 999}'

curl -X POST http://localhost:8001/ \
  -d "email=alice@example.com&password=secret123"

curl -X POST http://localhost:8001/ \
  -F "profile_photo=@photo.jpg" \ # Upload file
  -F "username=alice"
